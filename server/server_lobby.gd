extends Node


func _ready() -> void:
	Network.initialize_network(true)
	get_tree().connect("network_peer_connected", self, "_client_joined_server")
	get_tree().connect("network_peer_disconnected", self, "_client_left_server")


func _client_joined_server(id: int) -> void:
	State.add_player(id)
	var username: String = State.players[id].username
	for peer in State.get_peer_ids(id):
		rpc_id(peer, "player_joined", username, id)


func _client_left_server(id: int) -> void:
	var username: String = State.players[id].username
	State.remove_player(id)
	for peer in State.get_peer_ids(id):
		rpc_id(peer, "player_left", username, id)


remote func client_ready(id: int) -> void:
	State.make_player_ready(id)
	if State.players.size() > 1 and State.all_players_ready():
		rpc("start_match")
		get_tree().change_scene("res://server/match/server_match.tscn")
