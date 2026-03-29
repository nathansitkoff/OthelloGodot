extends Control

enum GameMode { HUMAN_VS_HUMAN, HUMAN_VS_AI }

@onready var board: Control = %Board
@onready var status_label: Label = %StatusLabel
@onready var score_label: Label = %ScoreLabel
@onready var new_game_button: Button = %NewGameButton
@onready var mode_button: OptionButton = %ModeButton

var game_logic: GameLogic
var ai_player: AIPlayer
var game_mode: GameMode = GameMode.HUMAN_VS_HUMAN
var ai_thinking: bool = false


func _ready() -> void:
	game_logic = GameLogic.new()
	new_game_button.pressed.connect(_on_new_game)
	mode_button.add_item("Human vs Human", 0)
	mode_button.add_item("Human vs AI", 1)
	mode_button.item_selected.connect(_on_mode_selected)
	board.move_made.connect(_on_move_made)
	_start_game()


func _on_new_game() -> void:
	_start_game()


func _on_mode_selected(index: int) -> void:
	game_mode = index as GameMode
	_start_game()


func _start_game() -> void:
	game_logic.reset()
	ai_thinking = false
	if game_mode == GameMode.HUMAN_VS_AI:
		ai_player = AIPlayer.new(GameLogic.Piece.WHITE)
	else:
		ai_player = null
	_update_display()


func _on_move_made(pos: Vector2i) -> void:
	if ai_thinking:
		return
	game_logic.make_move(pos, game_logic.current_player)
	_advance_turn()


func _advance_turn() -> void:
	game_logic.current_player = game_logic.get_opponent(game_logic.current_player)

	if game_logic.is_game_over():
		_update_display()
		_show_game_over()
		return

	# Skip turn if no valid moves
	if game_logic.get_valid_moves(game_logic.current_player).size() == 0:
		game_logic.current_player = game_logic.get_opponent(game_logic.current_player)

	_update_display()

	# AI turn
	if game_mode == GameMode.HUMAN_VS_AI and game_logic.current_player == GameLogic.Piece.WHITE:
		_do_ai_turn()


func _do_ai_turn() -> void:
	ai_thinking = true
	status_label.text = "AI thinking..."
	board.update_state(game_logic, [])
	# Brief delay so UI updates before AI blocks
	await get_tree().create_timer(0.1).timeout
	var move := ai_player.get_best_move(game_logic)
	if move != Vector2i(-1, -1):
		game_logic.make_move(move, GameLogic.Piece.WHITE)
	ai_thinking = false
	_advance_turn()


func _update_display() -> void:
	var valid_moves := game_logic.get_valid_moves(game_logic.current_player)
	board.update_state(game_logic, valid_moves)
	var score := game_logic.get_score()
	score_label.text = "Black: %d  |  White: %d" % [score.black, score.white]
	var turn_name := "Black" if game_logic.current_player == GameLogic.Piece.BLACK else "White"
	status_label.text = "%s's turn" % turn_name


func _show_game_over() -> void:
	var score := game_logic.get_score()
	if score.black > score.white:
		status_label.text = "Black wins! (%d - %d)" % [score.black, score.white]
	elif score.white > score.black:
		status_label.text = "White wins! (%d - %d)" % [score.white, score.black]
	else:
		status_label.text = "Draw! (%d - %d)" % [score.black, score.white]
