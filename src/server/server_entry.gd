extends Node


func _ready() -> void:
	Network.initialize_network(true)
	get_tree().connect("network_peer_connected", self, "_client_joined_server")
	get_tree().connect("network_peer_disconnected", self, "_client_left_server")


func _client_joined_server(id: int) -> void:
	print("%s has joined the server" % id)


func _client_left_server(id: int) -> void:
	print("%s has left the server" % id)
