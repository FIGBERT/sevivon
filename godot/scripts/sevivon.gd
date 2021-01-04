extends RigidBody

const ACCEL_THRESHOLD := 3
const MIN_ANGLE := 0.0
const MAX_ANGLE := 0.1
const MIN_FORCE := 5
const MAX_FORCE := 12
var has_spun := false

func _physics_process(_delta):
	var accel := Input.get_accelerometer()
	if accel.length() > ACCEL_THRESHOLD:
		spin(accel)

func spin(accel: Vector3):
	randomize()
	angular_velocity = Vector3(rand_range(MIN_ANGLE, MAX_ANGLE), 0, rand_range(MIN_ANGLE, MAX_ANGLE))
	apply_torque_impulse(Vector3.UP * accel.length() * rand_range(MIN_FORCE, MAX_FORCE))
	has_spun = true
