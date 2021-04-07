extends Node


const SERVER_PORT := 1780
const MAX_PLAYERS := 5
var SERVER_IP := "135.181.44.54" if OS.has_feature("release") else "10.0.0.76"


func _ready() -> void:
	reset_network()
	State.reset_state()


func reset_network() -> void:
	var peer = get_tree().network_peer
	if peer != null:
		peer.close_connection()


func initialize_network(server := false) -> void:
	var peer := NetworkedMultiplayerENet.new()
	if server:
		peer.create_server(SERVER_PORT, MAX_PLAYERS)
	else:
		peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().set_network_peer(peer)
