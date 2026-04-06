extends Node3D

const BALL_SCENE := preload("res://scenes/ball.tscn")

@onready var paddle: CharacterBody3D = $Paddle

var _ball: RigidBody3D = null


func _ready() -> void:
	add_to_group("main")
	GameManager.game_over.connect(_on_game_over)
	_start_game()


func _start_game() -> void:
	GameManager.start_game()
	_spawn_ball()


func _spawn_ball() -> void:
	_ball = BALL_SCENE.instantiate() as RigidBody3D
	add_child(_ball)
	paddle.attach_ball(_ball)


func _on_ball_died(ball: RigidBody3D) -> void:
	if GameManager.is_playing:
		paddle.attach_ball(ball)


func _on_game_over() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("launch_ball") and not GameManager.is_playing:
		_restart()


func _restart() -> void:
	if _ball:
		_ball.queue_free()
	await get_tree().process_frame
	_start_game()
