extends Node

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal game_over

var score: int = 0
var lives: int = 3
var is_playing: bool = false


func start_game() -> void:
	score = 0
	lives = 3
	is_playing = true
	score_changed.emit(score)
	lives_changed.emit(lives)


func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		is_playing = false
		game_over.emit()


func reset() -> void:
	score = 0
	lives = 3
	is_playing = false
