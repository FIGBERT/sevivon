extends Node


const ACCEL_THRESHOLD := 3
const SERVER_IP := "10.0.0.76"
const SERVER_PORT := 1780
const MAX_PLAYERS := 2
const DREIDEL_FACES := ["nun", "gimmel", "hey", "pey/shin"]
var players := {}
var pot := 5
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


func _client_joined_server(id: int) -> void:
	print("%s joined successfully" % id)
	if players.size() > 0:
		var peers := _join_array(players.keys(), "\n    ")
		var message: String = "Some players are already here:\n    %s" % peers
		rpc_id(id, "print_message_from_server", message)
	for player in players:
		var message := "%s has joined the server!" % id
		rpc_id(player, "print_message_from_server", message)
	players[id] = { "gelt": 10, "out": false }


func _client_left_server(id: int) -> void:
	print("%s disconnected from the server" % id)
	players.erase(id)
	for player in players:
		var message := "%s has left the server." % id
		rpc_id(player, "print_message_from_server", message)


func _start_game() -> void:
	get_tree().set_refuse_new_network_connections(true)
	rset("game_started", true)
	rpc("print_message_from_server", "The game has begun!")
	rset("current_turn", { "id": players.keys()[0], "index": 0 })
	rpc("print_message_from_server", "It's %s's turn" % current_turn["id"])
	rpc("print_message_from_server", _gelt_status())


func _end_game(message: String, over := false) -> void:
	get_tree().set_refuse_new_network_connections(false)
	rset("game_started", false)
	rset("game_over", over)
	rset("current_turn", { "id": -1, "index": -1 })
	rpc("print_message_from_server", message)


func _check_for_winner() -> int:
	var winner: int
	for id in players.keys():
		if not players[id]["out"]:
			if winner == null:
				winner = id
			elif winner != -1:
				winner = -1
	return winner


func _iterate_turn() -> void:
	var index: int
	if current_turn["index"] == players.size() - 1:
		index = 0
	else:
		index = current_turn["index"] + 1
	var id = players.keys()[index]
	if players[id]["out"]:
		_iterate_turn()
	rset("current_turn", { "id": id, "index": index })
	rpc("print_message_from_server", "It's now %s's turn" % current_turn["id"])


func _gelt_status() -> String:
	var message := "Current gelt status:\n    Pot: %s\n" % pot
	for id in players.keys():
		message += "    %s: %s\n" % [id, players[id]["gelt"]]
	return message


func _spin_dreidel(id: int) -> void:
	randomize()
	var spin: int = floor(rand_range(0, 4))
	var result: String = DREIDEL_FACES[spin]
	rpc("print_message_from_server", "%s landed on %s!" % [id, result])
	match(spin):
		1: # gimel
			players[id]["gelt"] += pot
			pot = 0
			_everyone_puts_in_one()
		2: # hey
			players[id]["gelt"] += floor(pot / 2)
			pot -= floor(pot / 2)
			if pot == 1:
				_everyone_puts_in_one()
		3: # shin
			if players[id]["gelt"] != 0:
				players[id]["gelt"] -= 1
				pot += 1
			else:
				players[id]["out"] = true


func _everyone_puts_in_one() -> void:
	for id in players.keys():
		if players[id]["gelt"] != 0:
			players[id]["gelt"] -= 1
			pot += 1
		else:
			players[id]["out"] = true


remote func client_spun() -> void:
	var sender := get_tree().get_rpc_sender_id()
	if sender != current_turn["id"]:
		return
	rpc("print_message_from_server", "%s has spun the dreidel..." % sender)
	_spin_dreidel(sender)
	rpc("print_message_from_server", _gelt_status())
	var winner = _check_for_winner()
	if winner > -1:
		_end_game("%s has won the game! Congratulations!", true)
	else:
		_iterate_turn()


## Client Logic
func _initialize_client() -> void:
	var peer := NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().network_peer = peer
	get_tree().connect("connected_to_server", self, "_client_connected_successfully")
	get_tree().connect("connection_failed", self, "_client_connection_failed")


func _client_connected_successfully() -> void:
	$Label.text += "Connection to server established as %s.\n" % get_tree().get_network_unique_id()


func _client_connection_failed() -> void:
	$Label.text += "Could not connect to server.\n"


func _check_for_spin() -> void:
	var accel := Input.get_accelerometer()
	if accel.length() > ACCEL_THRESHOLD:
		rpc_id(1, "client_spun")


remote func print_message_from_server(message: String) -> void:
	$Label.text += message + "\n"


## Utility Functions
func _join_array(array: Array, delimiter: String = "") -> String:
	var joined_string = ""
	for item in array.slice(0, -2):
		joined_string += "%s%s" % [item, delimiter]
	joined_string += str(array[-1])
	return joined_string
