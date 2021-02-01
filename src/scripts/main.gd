extends Node


const SERVER_IP := "10.0.0.76"
const SERVER_PORT := 1780
const MAX_PLAYERS := 2
var players := {}


func _ready() -> void:
	if "--server" in OS.get_cmdline_args() or OS.has_feature("Server"):
		_initialize_server()
	else:
		_initialize_client()


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
		var message: String = "Some players are already here:\n    %s\n" % peers
		rpc_id(id, "print_message_from_server", message)
	for player in players:
		var message := "%s has joined the server!\n" % id
		rpc_id(player, "print_message_from_server", message)
	players[id] = { "gelt": 10 }


func _client_left_server(id: int) -> void:
	print("%s disconnected from the server" % id)
	players.erase(id)
	for player in players:
		var message := "%s has left the server.\n" % id
		rpc_id(player, "print_message_from_server", message)


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


remote func print_message_from_server(message: String) -> void:
	$Label.text += message


## Utility Functions
func _join_array(array: Array, delimiter: String = "") -> String:
	var joined_string = ""
	for item in array.slice(0, -2):
		joined_string += "%s%s" % [item, delimiter]
	joined_string += str(array[-1])
	return joined_string
