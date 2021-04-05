extends Node


func _ready() -> void:
	var loading_scene: Node = load("res://src/client/loading/loading.tscn").instance()
	add_child(loading_scene)
	Network.initialize_network()
	get_tree().connect("connected_to_server", self, "_client_connected_successfully")
	get_tree().connect("connection_failed", $LoadingScreen, "failure")


func _client_connected_successfully() -> void:
	get_tree().change_scene("res://src/client/gameplay/gameplay.tscn")
