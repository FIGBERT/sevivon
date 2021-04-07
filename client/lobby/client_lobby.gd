extends Node



func _on_button_pressed() -> void:
	rpc_id(1, "client_ready", get_tree().get_network_unique_id())
	$UI/Button.hide()
	$UI/Label.show()
