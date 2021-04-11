extends Spatial


var ACCEL_THRESHOLD := 3 if OS.get_name() == "iOS" else 30
var spin_disabled := false


func _process(delta: float) -> void:
	var accel := Input.get_accelerometer()
	if accel.length() > ACCEL_THRESHOLD and not spin_disabled:
		rpc_id(1, "shake_action")
		spin_disabled = true
		yield(get_tree().create_timer(0.5), "timeout")
		spin_disabled = false


remote func vibrate_device() -> void:
	Input.vibrate_handheld()
