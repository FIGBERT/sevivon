extends Node


func _ready() -> void:
	var safe_area := OS.get_window_safe_area()
	$UI/JoinLabel.set_margin(MARGIN_TOP, safe_area.position.y)


func _on_button_pressed() -> void:
	rpc_id(1, "client_ready", get_tree().get_network_unique_id())
	$UI/ReadyButton.hide()
	$UI/WaitingLabel.show()


func _player_joined_or_left(username: String, id: int, join: bool) -> void:
	$UI/JoinLabel.set_text("%s (%s) %s the lobby" % [
			username, id, "joined" if join else "left"])
	yield(get_tree().create_timer(2), "timeout")
	$UI/JoinLabel.set_text("")


remote func player_joined(username: String, id: int) -> void:
	_player_joined_or_left(username, id, true)


remote func player_left(username: String, id: int) -> void:
	_player_joined_or_left(username, id, false)


remote func start_match() -> void:
	get_tree().change_scene("res://client/match/match.tscn")
