extends Node


const SERVER_IP := "10.0.0.76"
const SERVER_PORT := 1780
const MAX_PLAYERS := 2


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


func _client_left_server(id: int) -> void:
	print("%s disconnected from the server" % id)


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
