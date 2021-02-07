extends Node


const SERVER_IP := "10.0.0.76"
const SERVER_PORT := 1780
const MAX_PLAYERS := 2
const DREIDEL_FACES := ["nun", "gimmel", "hey", "pey/shin"]
const USERNAMES := ["Judah", "Yochanan", "Shimon", "Elazar", "Yonatan"]
const POT_STARTING_GELT := 5
const PLAYER_STARTING_GELT := 10
var ACCEL_THRESHOLD := 3 if OS.get_name() == "iOS" else 30
var players := {}
var pot := POT_STARTING_GELT
remotesync var game_started := false
remotesync var game_over := false
remotesync var current_turn := { "id": -1, "index": -1 }


func _ready() -> void:
	if "--server" in OS.get_cmdline_args() or OS.has_feature("Server"):
		_initialize_server()
	else:
		_initialize_client()


func _process(delta: float) -> void:
	if "--server" in OS.get_cmdline_args() or OS.has_feature("Server"):
		if players.size() == MAX_PLAYERS and not game_started and not game_over:
			_start_game()
		elif players.size() != MAX_PLAYERS and game_started and not game_over:
			_end_game("Missing players! Stopping the game...")
	else:
		if game_started and current_turn["id"] == get_tree().get_network_unique_id():
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
	}
	
	var username: String = players[id]["name"]
	var greeting: String = "Welcome to Sov! You're now known as %s." % username
	print("%s (%s) joined successfully" % [username, id])
	rpc_id(id, "print_message_from_server", greeting)
	
	var peers := _peers(id)
	if peers.size() > 0:
		var names := _join_array(_peers(id, true), "\n    ")
		var message: String = "Some players are already here:\n    %s" % names
		rpc_id(id, "print_message_from_server", message)
	for player in peers:
		var message: String = "%s has joined the server!" % username
		rpc_id(player, "print_message_from_server", message)


func _client_left_server(id: int) -> void:
	var username: String = players[id]["name"]
	print("%s (%s) disconnected from the server" % [username, id])
	players.erase(id)
	
	for player in players:
		var message := "%s has left the server." % username
		rpc_id(player, "print_message_from_server", message)


### Game Phases
func _start_game() -> void:
	get_tree().set_refuse_new_network_connections(true)
	rset("game_started", true)
	rpc("print_message_from_server", "The game has begun!")
	rset("current_turn", { "id": players.keys()[0], "index": 0 })
	var username: String = players[current_turn["id"]]["name"]
	rpc("print_message_from_server", "It's %s's turn" % username)
	rpc("print_message_from_server", _gelt_status())


func _end_game(message: String, over := false) -> void:
	get_tree().set_refuse_new_network_connections(false)
	rset("game_started", false)
	rset("game_over", over)
	rset("current_turn", { "id": -1, "index": -1 })
	for id in players.keys():
		players[id]["gelt"] = PLAYER_STARTING_GELT
		players[id]["in"] = true
	pot = POT_STARTING_GELT
	rpc("print_message_from_server", message)

### Dreidel Actions
remote func client_spun() -> void:
	var sender := get_tree().get_rpc_sender_id()
	if sender != current_turn["id"]:
		return
	rpc("print_message_from_server", "%s has spun the dreidel..." % players[sender]["name"])
	var needs_ante := _spin_dreidel(sender)
	if needs_ante:
		rpc("print_message_from_server", _gelt_status())
		rpc("print_message_from_server", "Time to ante up!")
		_everyone_puts_in_one()
	var has_won := _check_for_winner()
	if has_won:
		var winner := _find_winner()
		_end_game("We have a winner! Congratulations, %s!" % players[winner]["name"], true)
	else:
		rpc("print_message_from_server", _gelt_status())
		_iterate_turn()


func _spin_dreidel(id: int) -> bool:
	randomize()
	var username: String = players[id]["name"]
	var needs_ante := false
	var spin: int = floor(rand_range(0, 4))
	var result: String = DREIDEL_FACES[spin]
	rpc("print_message_from_server", "%s landed on %s!" % [username, result])
	match(spin):
		1: # gimmel
			players[id]["gelt"] += pot
			pot = 0
			needs_ante = true
		2: # hey
			players[id]["gelt"] += floor(pot / 2.0)
			pot -= floor(pot / 2.0)
			if pot == 1:
				needs_ante = true
		3: # pey/shin
			if players[id]["gelt"] > 0:
				players[id]["gelt"] -= 1
				pot += 1
			else:
				rpc("print_message_from_server", "%s can't pay – you lose!" % username)
				players[id]["in"] = false
	return needs_ante


func _everyone_puts_in_one() -> void:
	for id in players.keys():
		if not players[id]["in"]:
			continue
		if players[id]["gelt"] > 0:
			players[id]["gelt"] -= 1
			pot += 1
		else:
			var username: String = players[id]["name"]
			rpc("print_message_from_server", "%s can't pay the ante – you lose!" % username)
			players[id]["in"] = false


func _iterate_turn() -> void:
	var index: int
	if current_turn["index"] == players.size() - 1:
		index = 0
	else:
		index = current_turn["index"] + 1
	if not players[players.keys()[index]]["in"]:
		current_turn = { "id": players.keys()[index], "index": index }
		_iterate_turn()
	var id: int = players.keys()[index]
	var username: String = players[id]["name"]
	rset("current_turn", { "id": id, "index": index })
	rpc("print_message_from_server", "It's now %s's turn" % username)


### Winner
func _check_for_winner() -> bool:
	var sum := 0
	for id in players.keys():
		sum += int(players[id]["in"])
	return true if sum == 1 else false


func _find_winner() -> int:
	for id in players.keys():
		if players[id]["in"]:
			return id
	return -1


### Status and Debug
func _gelt_status() -> String:
	var message := "Current gelt status:\n    Pot: %s\n" % pot
	for id in players.keys():
		var username: String = players[id]["name"]
		var gelt: int = players[id]["gelt"]
		message += "    %s: %s\n" % [username, gelt]
	return message


## Client Logic
func _initialize_client() -> void:
	var peer := NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().network_peer = peer
	get_tree().connect("connected_to_server", self, "_client_connected_successfully")
	get_tree().connect("connection_failed", self, "_client_connection_failed")


func _client_connected_successfully() -> void:
	$Label.text += "Connection to server established.\n"


func _client_connection_failed() -> void:
	$Label.text += "Could not connect to server.\n"


func _check_for_spin() -> void:
	var accel := Input.get_accelerometer()
	if accel.length() > ACCEL_THRESHOLD:
		rpc_id(1, "client_spun")


remote func print_message_from_server(message: String) -> void:
	$Label.text += message + "\n"


## Utility Functions
func _join_array(array: Array, delimiter := "") -> String:
	var joined_string := ""
	for item in array.slice(0, -2):
		joined_string += "%s%s" % [item, delimiter]
	joined_string += str(array[-1])
	return joined_string


func _peers(id: int, names := false) -> Array:
	var peers_array := players.keys().duplicate()
	peers_array.erase(id)
	if names:
		var names_array := []
		for peer in peers_array:
			names_array.append(players[peer]["name"])
		return names_array
	return peers_array
