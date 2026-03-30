class_name MedalSystem
extends RefCounted

const SAVE_PATH := "user://medals.json"

# Each medal: {"id": str, "title": str, "detail": str, "color": str, "date": str}
var medals: Array = []


func _init() -> void:
	_load()


func award_medals(score: Dictionary, winner_piece: int, corners: int,
		move_count: int, vs_ai: bool, is_draw: bool) -> Array:
	if is_draw:
		_try_award("peacemaker", "Peacemaker", "Ended in a draw", "silver")
		return medals

	var winner_score: int = score.black if winner_piece == GameLogic.Piece.BLACK else score.white
	var loser_score: int = score.white if winner_piece == GameLogic.Piece.BLACK else score.black
	var margin := winner_score - loser_score
	var new_medals := []

	# First Win
	if not _has_medal("first_win"):
		new_medals.append(_award("first_win", "First Victory", "Won your first game", "gold"))

	# Best Blowout — largest margin (upgradeable)
	_try_best("best_blowout", "Best Blowout", "Won by %d pieces" % margin, margin)

	# Best Score — highest piece count (upgradeable)
	_try_best("best_score", "Best Score", "Finished with %d pieces" % winner_score, winner_score)

	# Shutout
	if loser_score == 0 and not _has_medal("shutout"):
		new_medals.append(_award("shutout", "Shutout", "Opponent ended with 0 pieces", "gold"))

	# Close Call — won by 1-2
	if margin <= 2 and not _has_medal("close_call"):
		new_medals.append(_award("close_call", "Close Call", "Won by just %d" % margin, "bronze"))

	# Corner Master — held 3+ corners
	if corners >= 3:
		var label := "All 4 corners" if corners == 4 else "Held %d corners" % corners
		_try_best("corner_master", "Corner Master", label, corners)

	# Speed Demon — won in fewest total moves (upgradeable, lower is better)
	_try_lowest("speed_demon", "Speed Demon", "Won in %d moves" % move_count, move_count)

	# AI Slayer
	if vs_ai and not _has_medal("ai_slayer"):
		new_medals.append(_award("ai_slayer", "AI Slayer", "Beat the computer", "gold"))

	# Domination — 50+ pieces
	if winner_score >= 50 and not _has_medal("domination"):
		new_medals.append(_award("domination", "Domination", "Finished with %d pieces" % winner_score, "gold"))

	# Collector milestone medals
	var total_wins := _get_win_count()
	total_wins += 1
	_set_win_count(total_wins)

	if total_wins == 5 and not _has_medal("veteran"):
		new_medals.append(_award("veteran", "Veteran", "Won 5 games", "silver"))
	if total_wins == 10 and not _has_medal("champion"):
		new_medals.append(_award("champion", "Champion", "Won 10 games", "gold"))
	if total_wins == 25 and not _has_medal("legend"):
		new_medals.append(_award("legend", "Legend", "Won 25 games", "gold"))

	_save()
	return new_medals


func get_all_medals() -> Array:
	return medals


func _has_medal(id: String) -> bool:
	for m in medals:
		if m.id == id:
			return true
	return false


func _get_medal(id: String) -> Dictionary:
	for m in medals:
		if m.id == id:
			return m
	return {}


func _award(id: String, title: String, detail: String, color: String) -> Dictionary:
	var medal := {"id": id, "title": title, "detail": detail, "color": color,
		"date": Time.get_date_string_from_system(), "value": 0}
	medals.append(medal)
	_save()
	return medal


func _try_award(id: String, title: String, detail: String, color: String) -> void:
	if not _has_medal(id):
		_award(id, title, detail, color)


func _try_best(id: String, title: String, detail: String, value: int) -> void:
	if _has_medal(id):
		var existing := _get_medal(id)
		if value > existing.get("value", 0):
			existing.title = title
			existing.detail = detail
			existing.value = value
			existing.date = Time.get_date_string_from_system()
			_save()
	else:
		var medal := _award(id, title, detail, "gold")
		medal.value = value


func _try_lowest(id: String, title: String, detail: String, value: int) -> void:
	if _has_medal(id):
		var existing := _get_medal(id)
		if value < existing.get("value", 9999):
			existing.title = title
			existing.detail = detail
			existing.value = value
			existing.date = Time.get_date_string_from_system()
			_save()
	else:
		var medal := _award(id, title, detail, "silver")
		medal.value = value


func _get_win_count() -> int:
	for m in medals:
		if m.id == "_win_count":
			return m.get("value", 0)
	return 0


func _set_win_count(count: int) -> void:
	for m in medals:
		if m.id == "_win_count":
			m.value = count
			return
	medals.append({"id": "_win_count", "title": "", "detail": "", "color": "", "value": count, "date": ""})


func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(medals))


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			medals = json.data
