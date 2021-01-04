extends RigidBody

const ACCEL_THRESHOLD := 3
const MIN_ANGLE := 0.0
const MAX_ANGLE := 0.1
const MIN_FORCE := 5
const MAX_FORCE := 12
var has_spun := false
var displayed_results := false

func _physics_process(_delta):
	var accel := Input.get_accelerometer()
	if accel.length() > ACCEL_THRESHOLD:
		spin(accel)
	elif has_spun && !displayed_results && is_zero_approx(angular_velocity.length()):
		print(spin_result())
		displayed_results = true
	elif displayed_results:
		get_tree().reload_current_scene()

func spin(accel: Vector3):
	randomize()
	angular_velocity = Vector3(rand_range(MIN_ANGLE, MAX_ANGLE), 0, rand_range(MIN_ANGLE, MAX_ANGLE))
	apply_torque_impulse(Vector3.UP * accel.length() * rand_range(MIN_FORCE, MAX_FORCE))
	has_spun = true

func spin_result() -> String:
	var nun_pos: float = $Body/Nun.global_transform.origin.y
	var gimel_pos: float = $Body/Gimel.global_transform.origin.y
	var hey_pos: float = $Body/Hey.global_transform.origin.y
	var pey_shin_pos: float
	if $Body/Pey.visible:
		pey_shin_pos = $Body/Pey.global_transform.origin.y
	else:
		pey_shin_pos = $Body/Shin.global_transform.origin.y
	var biggest = max(nun_pos, max(gimel_pos, (max(hey_pos, pey_shin_pos))))
	match biggest:
		nun_pos:
			return "NUN"
		gimel_pos:
			return "GIMEL"
		hey_pos:
			return "HEY"
		pey_shin_pos:
			return "PEY_SHIN"
		_:
			return "ERROR"
