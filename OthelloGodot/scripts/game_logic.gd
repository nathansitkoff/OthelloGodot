class_name GameLogic
extends RefCounted

enum Piece { EMPTY, BLACK, WHITE }

const BOARD_SIZE := 8
const DIRECTIONS := [
	Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1),
	Vector2i(0, -1),                   Vector2i(0, 1),
	Vector2i(1, -1),  Vector2i(1, 0),  Vector2i(1, 1)
]

var board: Array = []
var current_player: Piece = Piece.BLACK


func _init() -> void:
	reset()


func reset() -> void:
	board = []
	for row in range(BOARD_SIZE):
		var r := []
		for col in range(BOARD_SIZE):
			r.append(Piece.EMPTY)
		board.append(r)
	board[3][3] = Piece.WHITE
	board[3][4] = Piece.BLACK
	board[4][3] = Piece.BLACK
	board[4][4] = Piece.WHITE
	current_player = Piece.BLACK


func get_opponent(player: Piece) -> Piece:
	return Piece.WHITE if player == Piece.BLACK else Piece.BLACK


func is_on_board(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < BOARD_SIZE and pos.y >= 0 and pos.y < BOARD_SIZE


func get_flips(pos: Vector2i, player: Piece) -> Array:
	if board[pos.x][pos.y] != Piece.EMPTY:
		return []
	var all_flips := []
	var opponent := get_opponent(player)
	for dir in DIRECTIONS:
		var flips := []
		var current: Vector2i = pos + dir
		while is_on_board(current) and board[current.x][current.y] == opponent:
			flips.append(current)
			current += dir
		if flips.size() > 0 and is_on_board(current) and board[current.x][current.y] == player:
			all_flips.append_array(flips)
	return all_flips


func is_valid_move(pos: Vector2i, player: Piece) -> bool:
	return get_flips(pos, player).size() > 0


func get_valid_moves(player: Piece) -> Array:
	var moves := []
	for row in range(BOARD_SIZE):
		for col in range(BOARD_SIZE):
			var pos := Vector2i(row, col)
			if is_valid_move(pos, player):
				moves.append(pos)
	return moves


func make_move(pos: Vector2i, player: Piece) -> Array:
	var flips := get_flips(pos, player)
	if flips.size() == 0:
		return []
	board[pos.x][pos.y] = player
	for flip in flips:
		board[flip.x][flip.y] = player
	return flips


func get_score() -> Dictionary:
	var black := 0
	var white := 0
	for row in range(BOARD_SIZE):
		for col in range(BOARD_SIZE):
			if board[row][col] == Piece.BLACK:
				black += 1
			elif board[row][col] == Piece.WHITE:
				white += 1
	return {"black": black, "white": white}


func is_game_over() -> bool:
	return get_valid_moves(Piece.BLACK).size() == 0 and get_valid_moves(Piece.WHITE).size() == 0


func get_corners(player: Piece) -> int:
	var count := 0
	for pos in [Vector2i(0, 0), Vector2i(0, 7), Vector2i(7, 0), Vector2i(7, 7)]:
		if board[pos.x][pos.y] == player:
			count += 1
	return count


func duplicate_board() -> Array:
	var new_board := []
	for row in range(BOARD_SIZE):
		new_board.append(board[row].duplicate())
	return new_board
