extends Control

signal move_made(pos: Vector2i)

const PIECE_SHADOW_COLOR := Color(0.0, 0.0, 0.0, 0.25)
const FRAME_WIDTH := 12.0

var color_settings: ColorSettings
var game_logic: GameLogic
var valid_moves: Array = []
var cell_size: float = 0.0
var board_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_on_resized)


func set_color_settings(settings: ColorSettings) -> void:
	color_settings = settings
	color_settings.colors_changed.connect(queue_redraw)


func update_state(logic: GameLogic, moves: Array) -> void:
	game_logic = logic
	valid_moves = moves
	queue_redraw()


func _on_resized() -> void:
	queue_redraw()


func _calculate_layout() -> void:
	var available := minf(size.x, size.y) - FRAME_WIDTH * 2.0
	cell_size = available / GameLogic.BOARD_SIZE
	var board_size := cell_size * GameLogic.BOARD_SIZE
	board_offset = Vector2(
		(size.x - board_size) / 2.0,
		(size.y - board_size) / 2.0
	)


func _draw() -> void:
	if game_logic == null or color_settings == null:
		return
	_calculate_layout()

	var total := cell_size * GameLogic.BOARD_SIZE

	_draw_frame(total)
	_draw_felt(total)
	_draw_grid(total)
	_draw_star_points()
	_draw_valid_moves()
	_draw_pieces()


func _draw_frame(total: float) -> void:
	var frame_color := color_settings.get_frame_color()
	var frame_light := color_settings.get_frame_light()
	var frame_dark := color_settings.get_frame_dark()

	var outer := Rect2(
		board_offset - Vector2(FRAME_WIDTH, FRAME_WIDTH),
		Vector2(total + FRAME_WIDTH * 2.0, total + FRAME_WIDTH * 2.0)
	)
	draw_rect(outer, frame_dark)
	var inner_bevel := Rect2(
		outer.position + Vector2(2, 2),
		outer.size - Vector2(4, 4)
	)
	draw_rect(inner_bevel, frame_light)
	var main_frame := Rect2(
		outer.position + Vector2(3, 3),
		outer.size - Vector2(4, 4)
	)
	draw_rect(main_frame, frame_color)
	var board_rect := Rect2(board_offset, Vector2(total, total))
	draw_rect(Rect2(board_rect.position - Vector2(2, 2), board_rect.size + Vector2(4, 4)), frame_dark)


func _draw_felt(total: float) -> void:
	draw_rect(Rect2(board_offset, Vector2(total, total)), color_settings.board_color)
	var light := color_settings.get_board_light()
	for row in range(GameLogic.BOARD_SIZE):
		for col in range(GameLogic.BOARD_SIZE):
			if (row + col) % 2 == 0:
				var rect := Rect2(
					board_offset + Vector2(col * cell_size, row * cell_size),
					Vector2(cell_size, cell_size)
				)
				draw_rect(rect, light)


func _draw_grid(total: float) -> void:
	var line_color := color_settings.get_line_color()
	for i in range(GameLogic.BOARD_SIZE + 1):
		var x := board_offset.x + i * cell_size
		var y := board_offset.y + i * cell_size
		var width := 2.0 if (i == 0 or i == GameLogic.BOARD_SIZE) else 1.0
		draw_line(Vector2(x, board_offset.y), Vector2(x, board_offset.y + total), line_color, width)
		draw_line(Vector2(board_offset.x, y), Vector2(board_offset.x + total, y), line_color, width)


func _draw_star_points() -> void:
	var dot_radius := cell_size * 0.06
	var line_color := color_settings.get_line_color()
	for point in [Vector2(2, 2), Vector2(2, 6), Vector2(6, 2), Vector2(6, 6)]:
		var center := board_offset + Vector2(point.y * cell_size, point.x * cell_size)
		draw_circle(center, dot_radius, line_color)


func _draw_valid_moves() -> void:
	var highlight := color_settings.get_highlight_color()
	for move in valid_moves:
		var center := board_offset + Vector2(
			move.y * cell_size + cell_size / 2.0,
			move.x * cell_size + cell_size / 2.0
		)
		draw_circle(center, cell_size * 0.12, highlight)


func _draw_pieces() -> void:
	var radius := cell_size * 0.40
	for row in range(GameLogic.BOARD_SIZE):
		for col in range(GameLogic.BOARD_SIZE):
			var piece: int = game_logic.board[row][col]
			if piece == GameLogic.Piece.EMPTY:
				continue
			var center := board_offset + Vector2(
				col * cell_size + cell_size / 2.0,
				row * cell_size + cell_size / 2.0
			)
			var is_token1 := piece == GameLogic.Piece.BLACK
			_draw_piece(center, radius, is_token1)


func _draw_piece(center: Vector2, radius: float, is_token1: bool) -> void:
	var base: Color = color_settings.token1_color if is_token1 else color_settings.token2_color
	var highlight := color_settings.get_token_highlight(base)
	var shadow := color_settings.get_token_shadow(base)
	var bevel_offset := Vector2(-1.5, -2.0)

	# Drop shadow
	draw_circle(center + Vector2(2, 3), radius * 0.95, PIECE_SHADOW_COLOR)

	# Bottom-right shadow edge
	draw_circle(center - bevel_offset, radius, shadow)

	# Top-left light edge
	draw_circle(center + bevel_offset, radius, highlight)

	# Flat top face
	draw_circle(center, radius * 0.90, base)


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
