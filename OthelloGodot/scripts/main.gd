extends Control

enum GameMode { HUMAN_VS_HUMAN, HUMAN_VS_AI }

@onready var board: Control = %Board
@onready var status_label: Label = %StatusLabel
@onready var score_label: Label = %ScoreLabel
@onready var new_game_button: Button = %NewGameButton
@onready var mode_button: OptionButton = %ModeButton
@onready var victory_overlay: Control = %VictoryOverlay
@onready var trophy_room: Control = %TrophyRoom
@onready var trophy_button: Button = %TrophyButton
@onready var settings_menu: Control = %SettingsMenu
@onready var settings_button: Button = %SettingsButton
@onready var piece_sfx: AudioStreamPlayer = %PieceSFX

var game_logic: GameLogic
var medal_system: MedalSystem
var color_settings: ColorSettings
var ai_player: AIPlayer
var game_mode: GameMode = GameMode.HUMAN_VS_HUMAN
var ai_thinking: bool = false
var move_count: int = 0
var history: Array = []  # Array of {board, player, move_count}


func _ready() -> void:
	game_logic = GameLogic.new()
	medal_system = MedalSystem.new()
	color_settings = ColorSettings.new()
	board.set_color_settings(color_settings)
	piece_sfx.stream = SFX.create_piece_place_sound()
	new_game_button.pressed.connect(_on_new_game)
	trophy_button.pressed.connect(_on_trophy_button)
	settings_button.pressed.connect(_on_settings_button)
	mode_button.add_item("Human vs Human", 0)
	mode_button.add_item("Human vs AI", 1)
	mode_button.item_selected.connect(_on_mode_selected)
	board.move_made.connect(_on_move_made)
	%UndoButton.pressed.connect(_on_undo)
	_start_game()


func _on_new_game() -> void:
	trophy_room.hide_room()
	settings_menu.hide_menu()
	_start_game()


func _on_trophy_button() -> void:
	settings_menu.hide_menu()
	if trophy_room._visible_state:
		trophy_room.hide_room()
	else:
		trophy_room.show_room(medal_system)


func _on_settings_button() -> void:
	trophy_room.hide_room()
	if settings_menu._visible_state:
		settings_menu.hide_menu()
	else:
		settings_menu.show_menu(color_settings)


func _on_mode_selected(index: int) -> void:
	game_mode = index as GameMode
	_start_game()


func _start_game() -> void:
	game_logic.reset()
	ai_thinking = false
	move_count = 0
	history.clear()
	if game_mode == GameMode.HUMAN_VS_AI:
		ai_player = AIPlayer.new(GameLogic.Piece.WHITE)
	else:
		ai_player = null
	victory_overlay.hide_victory()
	_update_display()


func _on_move_made(pos: Vector2i) -> void:
	if ai_thinking:
		return
	_save_state()
	game_logic.make_move(pos, game_logic.current_player)
	move_count += 1
	piece_sfx.play()
	_advance_turn()


func _save_state() -> void:
	history.append({
		"board": game_logic.duplicate_board(),
		"player": game_logic.current_player,
		"move_count": move_count,
	})


func _on_undo() -> void:
	if ai_thinking or history.is_empty():
		return
	# In vs AI mode, undo both the AI move and the player's move
	if game_mode == GameMode.HUMAN_VS_AI and history.size() >= 2:
		history.pop_back()
	var state: Dictionary = history.pop_back()
	game_logic.board = state.board
	game_logic.current_player = state.player
	move_count = state.move_count
	victory_overlay.hide_victory()
	_update_display()


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
		_save_state()
		game_logic.make_move(move, GameLogic.Piece.WHITE)
		move_count += 1
		piece_sfx.play()
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
	var winner: String
	var score_str: String
	var is_draw := false
	var black_wins := true
	var winner_piece: int = GameLogic.Piece.BLACK

	if score.black > score.white:
		winner = "BLACK WINS!"
		score_str = "%d - %d" % [score.black, score.white]
		status_label.text = "Black wins! (%d - %d)" % [score.black, score.white]
	elif score.white > score.black:
		winner = "WHITE WINS!"
		score_str = "%d - %d" % [score.white, score.black]
		black_wins = false
		winner_piece = GameLogic.Piece.WHITE
		status_label.text = "White wins! (%d - %d)" % [score.white, score.black]
	else:
		winner = "DRAW!"
		score_str = "%d - %d" % [score.black, score.white]
		is_draw = true
		status_label.text = "Draw! (%d - %d)" % [score.black, score.white]

	# Award medals
	var corners := game_logic.get_corners(winner_piece)
	medal_system.award_medals(score, winner_piece, corners, move_count,
		game_mode == GameMode.HUMAN_VS_AI, is_draw)

	victory_overlay.show_victory(winner, score_str, is_draw, black_wins)
