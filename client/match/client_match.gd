extends Spatial


const ALERT_TEMPLATE = "%s spun:\n%s"
var ACCEL_THRESHOLD := 3 if OS.get_name() == "iOS" else 30
var spin_disabled := false


func _ready() -> void:
	var safe_area := OS.get_window_safe_area()
	$UI.set_margin(MARGIN_TOP, safe_area.position.y)
	_generate_ui()


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
			$UI/BottomLeft.name = str(keys[0])
			$UI/BottomCenter.name = str(keys[1])
			$UI/BottomRight.name = str(keys[2])
			$UI/TopLeft.name = str(keys[3])
			$UI/TopRight.name = str(keys[4])
		4:
			$UI/BottomLeft.name = str(keys[0])
			$UI/BottomCenter.name = str(keys[1])
			$UI/BottomRight.name = str(keys[2])
			$UI/TopCenter.name = str(keys[3])
		3:
			$UI/BottomLeft.name = str(keys[0])
			$UI/BottomCenter.name = str(keys[1])
			$UI/BottomRight.name = str(keys[2])
		2:
			$UI/BottomLeft.name = str(keys[0])
			$UI/BottomRight.name = str(keys[1])
	for id in keys:
		var node := get_node("UI/%s" % id)
		node.set_username(State.players.get(id).get("name"))
	$UI/Gelt.set_username("Gelt")
	_update_gelt()


func _update_gelt() -> void:
	$UI/Gelt.set_gelt(State.pot)
	for id in State.players.keys():
		var node := get_node("UI/%s" % id)
		var player: Dictionary = State.players.get(id)
		if not player.get("in"):
			node.set_color(Color.darkgray)
			node.set_gelt(0)
		else:
			if not player.get("paid_ante"):
				node.set_color(Color.darkred)
			elif id == State.current_turn and State.all_players_anted():
				node.set_color(Color.darkgreen)
			else:
				node.set_color(Color.white)
			node.set_gelt(player.get("gelt"))


remote func show_spin_alert(spin: int, username: String):
	var result: String
	match spin:
		0: result = "nun"
		1: result = "gimmel"
		2: result = "hey"
		3: result = "shin"
	$Spin.play(result)
	yield($Spin, "animation_finished")
	rpc_id(1, "finished_spin")
	$Sevivon.set_identity()
	$Sevivon.global_translate(Vector3(0, 0.812, 0))
	$UI/SpinPopup/Result.set_text(ALERT_TEMPLATE % [username, result.capitalize()])
	$UI/SpinPopup.popup_centered()
	yield(get_tree().create_timer(1), "timeout")
	$UI/SpinPopup.visible = false


remote func game_over(username: String, disconnect := false):
	if !disconnect:
		$UI/SpinPopup/Result.set_text("%s has won the game!\nThanks for playing!" % username)
	else:
		$UI/SpinPopup/Result.set_text("%s has disconnected.\nThanks for playing!" % username)
	$UI/SpinPopup.popup_centered()
	yield(get_tree().create_timer(2), "timeout")
	$UI/SpinPopup.visible = false
	get_tree().change_scene("res://client/client_entry.tscn")


remote func update_ui() -> void:
	_update_gelt()


remote func vibrate_device() -> void:
	Input.vibrate_handheld()
