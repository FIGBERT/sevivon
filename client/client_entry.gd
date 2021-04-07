extends Control


const FAILURE_MESSAGE := "Connection to server failed."
var safe_area := OS.get_window_safe_area()
var connection_failed := false
var dots := 0


func _ready() -> void:
	self.set_margin(MARGIN_TOP, safe_area.position.y)
	Network.initialize_network()
	get_tree().connect("connected_to_server", self, "_connection_successful")
	get_tree().connect("connection_failed", self, "_connection_failed")


func _connection_successful() -> void:
	get_tree().change_scene("res://client/lobby/lobby.tscn")


func _connection_failed() -> void:
	$Message.text = FAILURE_MESSAGE
	connection_failed = true
