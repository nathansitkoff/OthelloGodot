extends Control

signal move_made(pos: Vector2i)

const BOARD_COLOR := Color(0.0, 0.5, 0.0)
const LINE_COLOR := Color(0.0, 0.0, 0.0)
const BLACK_COLOR := Color(0.1, 0.1, 0.1)
const WHITE_COLOR := Color(0.95, 0.95, 0.95)
const HIGHLIGHT_COLOR := Color(0.0, 0.8, 0.0, 0.4)

var game_logic: GameLogic
var valid_moves: Array = []
var cell_size: float = 0.0
var board_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_on_resized)


func update_state(logic: GameLogic, moves: Array) -> void:
	game_logic = logic
	valid_moves = moves
	queue_redraw()


func _on_resized() -> void:
	queue_redraw()


func _calculate_layout() -> void:
	var available := minf(size.x, size.y)
	cell_size = available / GameLogic.BOARD_SIZE
	var board_size := cell_size * GameLogic.BOARD_SIZE
	board_offset = Vector2(
		(size.x - board_size) / 2.0,
		(size.y - board_size) / 2.0
	)


func _draw() -> void:
	if game_logic == null:
		return
	_calculate_layout()

	var total_board_size := cell_size * GameLogic.BOARD_SIZE

	# Board background
	draw_rect(Rect2(board_offset, Vector2(total_board_size, total_board_size)), BOARD_COLOR)

	# Grid lines
	for i in range(GameLogic.BOARD_SIZE + 1):
		var x := board_offset.x + i * cell_size
		var y := board_offset.y + i * cell_size
		draw_line(Vector2(x, board_offset.y), Vector2(x, board_offset.y + total_board_size), LINE_COLOR, 2.0)
		draw_line(Vector2(board_offset.x, y), Vector2(board_offset.x + total_board_size, y), LINE_COLOR, 2.0)

	# Valid move highlights
	for move in valid_moves:
		var center := board_offset + Vector2(
			move.y * cell_size + cell_size / 2.0,
			move.x * cell_size + cell_size / 2.0
		)
		draw_circle(center, cell_size * 0.15, HIGHLIGHT_COLOR)

	# Pieces
	var piece_radius := cell_size * 0.4
	for row in range(GameLogic.BOARD_SIZE):
		for col in range(GameLogic.BOARD_SIZE):
			var piece: int = game_logic.board[row][col]
			if piece != GameLogic.Piece.EMPTY:
				var center := board_offset + Vector2(
					col * cell_size + cell_size / 2.0,
					row * cell_size + cell_size / 2.0
				)
				var color := BLACK_COLOR if piece == GameLogic.Piece.BLACK else WHITE_COLOR
				draw_circle(center, piece_radius, color)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if game_logic == null:
			return
		_calculate_layout()
		var local_pos: Vector2 = event.position - board_offset
		var col := int(local_pos.x / cell_size)
		var row := int(local_pos.y / cell_size)
		if row >= 0 and row < GameLogic.BOARD_SIZE and col >= 0 and col < GameLogic.BOARD_SIZE:
			var pos := Vector2i(row, col)
			if pos in valid_moves:
				move_made.emit(pos)
