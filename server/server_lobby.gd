extends Node


func _ready() -> void:
	Network.initialize_network(true)
	get_tree().connect("network_peer_connected", self, "_client_joined_server")
	get_tree().connect("network_peer_disconnected", self, "_client_left_server")


func _client_joined_server(id: int) -> void:
	State.add_player(id)


func _client_left_server(id: int) -> void:
	State.remove_player(id)


remote func client_ready(id: int) -> void:
	State.make_player_ready(id)
	if State.all_players_ready():
		rpc("start_match")
