extends Node


func _ready() -> void:
	var me: Node = load("res://client/components/sevivon/sevivon.tscn").instance()
	me.translate(Vector3.BACK * 3)
	get_tree().get_root().add_child(me)


func _on_button_pressed() -> void:
	rpc_id(1, "client_ready", get_tree().get_network_unique_id())
	$UI/Button.hide()
	$UI/Label.show()


remote func start_match() -> void:
	get_tree().change_scene("res://client/match/match.tscn")
