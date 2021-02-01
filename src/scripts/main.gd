extends Node


const SERVER_IP := "10.0.0.76"
const SERVER_PORT := 1780
const MAX_PLAYERS := 2


func _ready() -> void:
	_initalize_instance()


func _initalize_instance() -> void:
	var is_server := "--server" in OS.get_cmdline_args() or OS.has_feature("Server")
	
	var peer := NetworkedMultiplayerENet.new()
	if is_server:
		peer.create_server(SERVER_PORT, MAX_PLAYERS)
	else:
		peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().network_peer = peer
	
	if not is_server:
		get_tree().connect("connected_to_server", self, "_connected_successfully")
		get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("network_peer_connected", self, "_peer_joined")
	get_tree().connect("network_peer_disconnected", self, "_peer_left")


func _peer_joined(id: int) -> void:
	if get_tree().is_network_server():
		print("%s joined successfully" % id)
	elif id != 1:
		$Label.text += "%s has joined the lobby\n" % id


func _peer_left(id: int) -> void:
	if get_tree().is_network_server():
		print("%s disconnected from the server" % id)
	elif id != 1:
		$Label.text += "%s has left the lobby\n" % id


func _connected_successfully() -> void:
	$Label.text += "Connection to server established.\n"


func _connection_failed() -> void:
	$Label.text += "Could not connect to server.\n"
