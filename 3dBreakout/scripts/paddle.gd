extends CharacterBody3D

## Paddle moves on the XZ plane (the open face of the room).
## WASD controls: W/S = forward/back (Z axis), A/D = left/right (X axis).
## Uses move_and_collide so it stops at walls automatically regardless of size.

@export var speed: float = 12.0

var _fixed_y: float
var _ball_attached: RigidBody3D = null


func _ready() -> void:
	_fixed_y = position.y


func _physics_process(delta: float) -> void:
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")

	if input.length() > 0.0:
		var motion := input.normalized() * speed * delta
		motion.y = 0.0
		move_and_collide(motion)

	# Lock Y so paddle never moves toward/away from camera
	position.y = _fixed_y

	if _ball_attached and Input.is_action_just_pressed("launch_ball"):
		_launch_ball()


func attach_ball(ball: RigidBody3D) -> void:
	_ball_attached = ball
	ball.reparent(self)
	ball.position = Vector3(0.0, -1.0, 0.0)
	ball.freeze = true


func _launch_ball() -> void:
	if not _ball_attached:
		return
	var ball := _ball_attached
	_ball_attached = null
	var world_pos := ball.global_position
	ball.reparent(get_parent())
	ball.global_position = world_pos
	ball.freeze = false
	var dir := Vector3(randf_range(-0.3, 0.3), -1.0, randf_range(-0.3, 0.3)).normalized()
	ball.linear_velocity = dir * 7.0
