extends Node


const SERVER_IP := "10.0.0.76"
const SERVER_PORT := 1780
const MAX_PLAYERS := 5


func _ready() -> void:
	if "--server" in OS.get_cmdline_args() or OS.has_feature("Server"):
		_initalize_server()
		get_tree().connect("network_peer_connected", self, "_client_joined")
		get_tree().connect("network_peer_disconnected", self, "_client_left")
	else:
		_initialize_client()
		get_tree().connect("connected_to_server", self, "_connected_successfully")
		get_tree().connect("connection_failed", self, "_connection_failed")


func _initalize_server() -> void:
	var peer := NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer


func _initialize_client() -> void:
	var peer := NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().network_peer = peer


func _client_joined(id: int) -> void:
	print("%s joined successfully" % id)


func _client_left(id: int) -> void:
	print("%s disconnected from the server" % id)


func _connected_successfully() -> void:
	print("Connection to server established.")


func _connection_failed() -> void:
	print("Could not connect to server.")
