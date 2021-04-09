extends Node


func _ready() -> void:
	var me: Node = load("res://client/components/sevivon/sevivon.tscn").instance()
	me.set_name(str(get_tree().get_network_unique_id()))
	me.translate(Vector3.BACK * 3)
	get_tree().get_root().add_child(me)


func _on_button_pressed() -> void:
	rpc_id(1, "client_ready", get_tree().get_network_unique_id())
	$UI/Button.hide()
	$UI/Label.show()
