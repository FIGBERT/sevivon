extends Spatial


const INDICATOR_TEMPLATE = "%s\n%s gelt"
const ALERT_TEMPLATE = "%s spun:\n%s"
var ACCEL_THRESHOLD := 3 if OS.get_name() == "iOS" else 30
var spin_disabled := false


func _ready() -> void:
	var safe_area := OS.get_window_safe_area()
	$UI.set_margin(MARGIN_TOP, safe_area.position.y)
	$Sevivon.set_username_tag(State.players[State.current_turn]["name"])
	_generate_ui()
	_update_indicators()


func _process(delta: float) -> void:
	var accel := Input.get_accelerometer()
	if accel.length() > ACCEL_THRESHOLD and not spin_disabled:
		rpc_id(1, "shake_action")
		spin_disabled = true
		yield(get_tree().create_timer(0.5), "timeout")
		spin_disabled = false


func _generate_ui() -> void:
	var keys := State.players.keys()
	match State.players.size():
		5:
			$UI/BottomCenter.name = str(keys[4])
			continue
		4:
			$UI/BottomRight.name = str(keys[3])
			continue
		3:
			$UI/BottomLeft.name = str(keys[2])
			continue
		2:
			$UI/TopRight.name = str(keys[1])
			$UI/TopLeft.name = str(keys[0])


func _update_indicators() -> void:
	$UI/Gelt.set_text(INDICATOR_TEMPLATE % ["Pot", State.pot])
	for id in State.players.keys():
		var node := get_node("UI/%s" % id)
		var player: Dictionary = State.players.get(id)
		if not player.get("in"):
			node.set("custom_colors/font_color", Color.darkgray)
			node.set_text(INDICATOR_TEMPLATE % [player.get("name"), 0])
		else:
			if not player.get("paid_ante"):
				node.set("custom_colors/font_color", Color.darkred)
			elif id == State.current_turn and State.all_players_anted():
				node.set("custom_colors/font_color", Color.darkgreen)
			else:
				node.set("custom_colors/font_color", Color.white)
			node.set_text(INDICATOR_TEMPLATE % [player.get("name"), player.get("gelt")])


remote func show_spin_alert(spin: int, username: String):
	var result: String
	match spin:
		0: result = "Nun"
		1: result = "Gimmel"
		2: result = "Hey"
		3: result = "Pey/Shin"
	$UI/SpinPopup/Result.set_text(ALERT_TEMPLATE % [username, result])
	$UI/SpinPopup.popup_centered()
	yield(get_tree().create_timer(1), "timeout")
	$UI/SpinPopup.visible = false


remote func update_ui() -> void:
	_update_indicators()


remote func vibrate_device() -> void:
	Input.vibrate_handheld()


remote func set_username_tag(username: String) -> void:
	$Sevivon.set_username_tag(username)
