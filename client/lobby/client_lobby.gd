extends Node


onready var players = preload("res://client/components/gameplay/players.gd").new()


func _ready() -> void:
	var me: Node = players.create_self()
	get_tree().get_root().add_child(me)


func _on_button_pressed() -> void:
	rpc_id(1, "client_ready", get_tree().get_network_unique_id())
	$UI/Button.hide()
	$UI/Label.show()
