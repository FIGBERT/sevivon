extends Control


var safe_area := OS.get_window_safe_area()


func _ready() -> void:
	self.set_margin(MARGIN_TOP, safe_area.position.y)


func _on_join_pressed() -> void:
	Network.initialize_network()
	get_tree().connect("connected_to_server", self, "_connection_successful")
	get_tree().connect("connection_failed", self, "_connection_failed")
	$Join.set_text("Connecting...")
	$Join.disabled = true


func _connection_successful() -> void:
	get_tree().change_scene("res://client/lobby/client_lobby.tscn")


func _connection_failed() -> void:
	$Popup.visible = true
	yield(get_tree().create_timer(2), "timeout")
	$Popup.visible = false
	$Join.set_text("Join a Game")
	$Join.disabled = false
