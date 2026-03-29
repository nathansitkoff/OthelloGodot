class_name AIPlayer
extends RefCounted

const POSITION_WEIGHTS := [
	[100, -20, 10,  5,  5, 10, -20, 100],
	[-20, -50, -2, -2, -2, -2, -50, -20],
	[ 10,  -2,  1,  1,  1,  1,  -2,  10],
	[  5,  -2,  1,  0,  0,  1,  -2,   5],
	[  5,  -2,  1,  0,  0,  1,  -2,   5],
	[ 10,  -2,  1,  1,  1,  1,  -2,  10],
	[-20, -50, -2, -2, -2, -2, -50, -20],
	[100, -20, 10,  5,  5, 10, -20, 100]
]

var max_depth: int
var ai_piece: GameLogic.Piece


func _init(piece: GameLogic.Piece, depth: int = 4) -> void:
	ai_piece = piece
	max_depth = depth


func get_best_move(logic: GameLogic) -> Vector2i:
	var valid_moves := logic.get_valid_moves(ai_piece)
	if valid_moves.size() == 0:
		return Vector2i(-1, -1)

	var best_score := -INF
	var best_move: Vector2i = valid_moves[0]

	for move in valid_moves:
		var saved_board := logic.duplicate_board()
		logic.make_move(move, ai_piece)
		var score := _minimax(logic, max_depth - 1, -INF, INF, false)
		logic.board = saved_board
		if score > best_score:
			best_score = score
			best_move = move

	return best_move


func _minimax(logic: GameLogic, depth: int, alpha: float, beta: float, maximizing: bool) -> float:
	if depth == 0 or logic.is_game_over():
		return _evaluate(logic)

	var player := ai_piece if maximizing else logic.get_opponent(ai_piece)
	var valid_moves := logic.get_valid_moves(player)

	if valid_moves.size() == 0:
		return _minimax(logic, depth - 1, alpha, beta, not maximizing)

	if maximizing:
		var max_eval := -INF
		for move in valid_moves:
			var saved_board := logic.duplicate_board()
			logic.make_move(move, player)
			var eval := _minimax(logic, depth - 1, alpha, beta, false)
			logic.board = saved_board
			max_eval = maxf(max_eval, eval)
			alpha = maxf(alpha, eval)
			if beta <= alpha:
				break
		return max_eval
	else:
		var min_eval := INF
		for move in valid_moves:
			var saved_board := logic.duplicate_board()
			logic.make_move(move, player)
			var eval := _minimax(logic, depth - 1, alpha, beta, true)
			logic.board = saved_board
			min_eval = minf(min_eval, eval)
			beta = minf(beta, eval)
			if beta <= alpha:
				break
		return min_eval


func _evaluate(logic: GameLogic) -> float:
	var score := 0.0
	var opponent := logic.get_opponent(ai_piece)
	for row in range(GameLogic.BOARD_SIZE):
		for col in range(GameLogic.BOARD_SIZE):
			if logic.board[row][col] == ai_piece:
				score += POSITION_WEIGHTS[row][col]
			elif logic.board[row][col] == opponent:
				score -= POSITION_WEIGHTS[row][col]
	return score
