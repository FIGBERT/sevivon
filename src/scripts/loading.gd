extends Label

const loading_message := "Connecting to server"
const failure_message := "Connection to server failed."
var safe_area := OS.get_window_safe_area()
var connection_failed := false
var dots := 0

func _ready() -> void:
	self.set_margin(MARGIN_TOP, safe_area.position.y)
	while not connection_failed:
		self.text = loading_message + ".".repeat(dots)
		yield(get_tree().create_timer(0.5), "timeout")
		if dots < 3:
			dots += 1
		else:
			dots = 0

func failure() -> void:
	self.text = failure_message
	connection_failed = true
