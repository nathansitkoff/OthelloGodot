extends RigidBody3D

## Ball bounces inside a 3D room. If it passes through the open top face
## (Y > death_y), the player loses a life.

@export var ball_speed: float = 7.0
@export var death_y: float = 5.5

var _initial_position: Vector3


func _ready() -> void:
	_initial_position = global_position
	contact_monitor = true
	max_contacts_reported = 4
	gravity_scale = 0.0


func _physics_process(_delta: float) -> void:
	if freeze:
		return

	# Keep speed constant
	if linear_velocity.length() > 0.1:
		linear_velocity = linear_velocity.normalized() * ball_speed

		# Prevent the ball from traveling nearly parallel to any axis
		var v := linear_velocity
		if absf(v.y) < 1.0:
			v.y = sign(v.y) * 1.0 if v.y != 0.0 else -1.0
			linear_velocity = v.normalized() * ball_speed

	# Death check: ball escaped past the open face
	if global_position.y > death_y:
		call_deferred("_die")


func _die() -> void:
	GameManager.lose_life()
	_reset_ball()


func _reset_ball() -> void:
	freeze = true
	global_position = _initial_position
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	get_tree().call_group("main", "_on_ball_died", self)
