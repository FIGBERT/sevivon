extends Node


signal client_anted
const SERVER_IP := "10.0.0.76" # Development
#const SERVER_IP := "135.181.44.54" # Production
const SERVER_PORT := 1780
const MAX_PLAYERS := 5
const DREIDEL_FACES := ["nun", "gimmel", "hey", "pey/shin"]
const USERNAMES := ["Judah", "Yochanan", "Shimon", "Elazar", "Yonatan"]
const POT_STARTING_GELT := 5
const PLAYER_STARTING_GELT := 10
var ACCEL_THRESHOLD := 3 if OS.get_name() == "iOS" else 30
var players := {}
var pot := POT_STARTING_GELT
var spin_disabled := false
remotesync var game_started := false
remotesync var current_turn := { "id": -1, "index": -1 }


func _ready() -> void:
	if "--server" in OS.get_cmdline_args() or OS.has_feature("Server"):
		_initialize_server()
	else:
		_initialize_client()


func _process(delta: float) -> void:
	if not ("--server" in OS.get_cmdline_args() or OS.has_feature("Server")):
		_check_for_spin()


## Server Logic
func _initialize_server() -> void:
	var peer := NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	get_tree().connect("network_peer_connected", self, "_client_joined_server")
	get_tree().connect("network_peer_disconnected", self, "_client_left_server")


### Network Peer Signals
func _client_joined_server(id: int) -> void:
	players[id] = {
		"name": USERNAMES[players.size()],
		"gelt": PLAYER_STARTING_GELT,
		"in": true,
		"paid_ante": true,
	}
	
	var username: String = players[id]["name"]
	var greeting: String = "Welcome to Sov! You're now known as %s." % username
	print("%s (%s) joined successfully" % [username, id])
	rpc_id(id, "print_message_from_server", greeting)
	
	var peers := _peers(id)
	var message := ""
	if peers.size() > 0:
		var names := _join_array(_peers(id, true), "\n    ")
		message = "Some players are already here:\n    %s" % names
	else:
		message = "You are the first player here – shake your phone to start the game once everybody's arrived!"
	rpc_id(id, "print_message_from_server", message)
	for player in peers:
		message = "%s has joined the server!" % username
		rpc_id(player, "print_message_from_server", message)


func _client_left_server(id: int) -> void:
	var username: String = players[id]["name"]
	print("%s (%s) disconnected from the server" % [username, id])
	players.erase(id)
	if players.size() > 0:
		_end_game("%s has left the server. Stopping the game." % username)


### Game Phases
func _start_game() -> void:
	get_tree().set_refuse_new_network_connections(true)
	rset("game_started", true)
	rpc("print_message_from_server", "The game has begun!")
	yield(get_tree().create_timer(0.5), "timeout")
	rset("current_turn", { "id": players.keys()[0], "index": 0 })
	var username: String = players[current_turn["id"]]["name"]
	rpc("print_message_from_server", "It's %s's turn" % username)
	rpc("print_message_from_server", _gelt_status())


func _end_game(message: String) -> void:
	get_tree().set_refuse_new_network_connections(false)
	rset("game_started", false)
	rset("current_turn", { "id": -1, "index": -1 })
	for id in players.keys():
		players[id]["gelt"] = PLAYER_STARTING_GELT
		players[id]["in"] = true
	pot = POT_STARTING_GELT
	rpc("print_message_from_server", message)
	rpc_id(players.keys()[0], "print_message_from_server", "To play again, shake your phone once everybody's ready!")


### Player Actions
remote func shake_action() -> void:
	var sender := get_tree().get_rpc_sender_id()
	if game_started:
		if sender == current_turn["id"] and players[sender]["in"] and _everyone_anted():
			_client_spun(sender)
			rpc_id(sender, "vibrate_device")
		elif not players[sender]["paid_ante"]:
			_send_ante_signal(sender)
			rpc_id(sender, "vibrate_device")
	else:
		if players.size() > 1 and sender == players.keys()[0]:
			_start_game()
			rpc_id(sender, "vibrate_device")


func _client_spun(sender: int) -> void:
	rpc("print_message_from_server", "%s has spun the dreidel..." % players[sender]["name"])
	yield(get_tree().create_timer(1), "timeout")
	_spin_dreidel(sender)
	rpc("print_message_from_server", _gelt_status())
	rpc("print_message_from_server", "Time to ante up!")
	yield(_everyone_puts_in_one(), "completed")
	var has_won := _check_for_winner()
	if has_won:
		var winner := _find_winner()
		_end_game("We have a winner! Congratulations, %s!" % players[winner]["name"])
	else:
		rpc("print_message_from_server", _gelt_status())
		_iterate_turn()


func _spin_dreidel(id: int) -> void:
	randomize()
	var username: String = players[id]["name"]
	var spin: int = floor(rand_range(0, 4))
	var result: String = DREIDEL_FACES[spin]
	rpc("print_message_from_server", "%s landed on %s!" % [username, result])
	match(spin):
		1: # gimmel
			players[id]["gelt"] += pot
			pot = 0
		2: # hey
			players[id]["gelt"] += ceil(pot / 2.0)
			pot -= ceil(pot / 2.0)
		3: # pey/shin
			if players[id]["gelt"] > 0:
				players[id]["gelt"] -= 1
				pot += 1
			else:
				rpc("print_message_from_server", "%s can't pay – you lose!" % username)
				players[id]["in"] = false


func _everyone_puts_in_one() -> void:
	for id in players.keys():
		if players[id]["in"]:
			players[id]["paid_ante"] = false
	
	while not _everyone_anted():
		var id: int = yield(self, "client_anted")
		var username: String = players[id]["name"]
		if not players[id]["in"] or players[id]["paid_ante"]:
			continue
		if players[id]["gelt"] > 0:
			players[id]["gelt"] -= 1
			pot += 1
			rpc("print_message_from_server", "%s has anted!" % username)
		else:
			rpc("print_message_from_server", "%s can't pay the ante – you lose!" % username)
			players[id]["in"] = false
		players[id]["paid_ante"] = true


func _iterate_turn() -> void:
	var index: int
	if current_turn["index"] == players.size() - 1:
		index = 0
	else:
		index = current_turn["index"] + 1
	var id: int = players.keys()[index]
	if not players[id]["in"]:
		current_turn = { "id": id, "index": index }
		_iterate_turn()
	else:
		var username: String = players[id]["name"]
		var new_turn := { "id": id, "index": index }
		rset("current_turn", new_turn)
		rpc("print_message_from_server", "It's now %s's turn" % username)


func _send_ante_signal(id: int) -> void:
	emit_signal("client_anted", id)


## Client Logic
func _initialize_client() -> void:
	var peer := NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().network_peer = peer
	get_tree().connect("connected_to_server", self, "_client_connected_successfully")
	get_tree().connect("connection_failed", self, "_client_connection_failed")
	var safe_area := OS.get_window_safe_area()
	$Label.set_margin(MARGIN_TOP, safe_area.position.y)


func _client_connected_successfully() -> void:
	$Label.text += "Connection to server established.\n"


func _client_connection_failed() -> void:
	$Label.text += "Could not connect to server.\n"


func _check_for_spin() -> void:
	var accel := Input.get_accelerometer()
	if accel.length() > ACCEL_THRESHOLD and not spin_disabled:
		rpc_id(1, "shake_action")
		_toggle_spin()


func _toggle_spin() -> void:
	spin_disabled = true
	yield(get_tree().create_timer(0.5), "timeout")
	spin_disabled = false


remote func print_message_from_server(message: String) -> void:
	$Label.text += message + "\n"


remote func vibrate_device() -> void:
	Input.vibrate_handheld()


## Utility Functions
func _everyone_anted() -> bool:
	return _compare_player_bool_properties("paid_ante", players.size())


func _check_for_winner() -> bool:
	return _compare_player_bool_properties("in", 1)


func _compare_player_bool_properties(prop: String, out: int) -> bool:
	var sum := 0
	for id in players.keys():
		sum += int(players[id][prop])
	return true if sum == out else false


func _find_winner() -> int:
	for id in players.keys():
		if players[id]["in"]:
			return id
	return -1


func _gelt_status() -> String:
	var message := "Current gelt status:\n    Pot: %s\n" % pot
	for id in players.keys():
		var username: String = players[id]["name"]
		var gelt := ""
		if players[id]["in"]:
			gelt = players[id]["gelt"]
		else:
			gelt = "Out"
		message += "    %s: %s\n" % [username, gelt]
	return message


func _peers(id: int, names := false) -> Array:
	var peers_array := players.keys().duplicate()
	peers_array.erase(id)
	if names:
		var names_array := []
		for peer in peers_array:
			names_array.append(players[peer]["name"])
		return names_array
	return peers_array


func _join_array(array: Array, delimiter := "") -> String:
	var joined_string := ""
	for item in array.slice(0, -2):
		joined_string += "%s%s" % [item, delimiter]
	joined_string += str(array[-1])
	return joined_string
