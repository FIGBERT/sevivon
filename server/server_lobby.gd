extends Node


signal username_request
const SERVER_PORT := 1780
const MAX_PLAYERS := 5


func _ready() -> void:
	if get_tree().network_peer != null:
		get_tree().network_peer.close_connection()
	State.reset_state()
	var peer := NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	get_tree().connect("network_peer_connected", self, "_client_joined_server")
	get_tree().connect("network_peer_disconnected", self, "_client_left_server")


func _client_joined_server(id: int) -> void:
	var username: String
	var set := false
	while not set:
		var out: Array = yield(self, "username_request")
		var sender: int = out[0]
		if sender == id:
			username = out[1]
			set = true
	State.add_player(id, username)
	for peer in State.get_peer_ids(id):
		rpc_id(peer, "player_joined", username, id)


func _client_left_server(id: int) -> void:
	var username: String = State.players[id]["name"]
	State.remove_player(id)
	for peer in State.get_peer_ids(id):
		rpc_id(peer, "player_left", username, id)


remote func client_ready(id: int) -> void:
	State.make_player_ready(id)
	if State.players.size() > 1 and State.all_players_ready():
		rpc("start_match")
		get_tree().change_scene("res://server/match/server_match.tscn")


remote func set_username(username: String) -> void:
	var id := get_tree().get_rpc_sender_id()
	emit_signal("username_request", id, username.strip_edges())
