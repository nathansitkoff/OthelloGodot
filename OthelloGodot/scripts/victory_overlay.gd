extends Control

const OVERLAY_COLOR := Color(0.0, 0.0, 0.0, 0.65)
const GOLD := Color(1.0, 0.84, 0.0)
const GOLD_DARK := Color(0.85, 0.65, 0.0)
const GOLD_LIGHT := Color(1.0, 0.95, 0.5)
const SILVER := Color(0.75, 0.75, 0.78)
const SILVER_DARK := Color(0.55, 0.55, 0.58)
const RIBBON_RED := Color(0.8, 0.15, 0.15)
const RIBBON_DARK := Color(0.6, 0.1, 0.1)

var winner_text: String = ""
var score_text: String = ""
var is_draw: bool = false
var winner_is_black: bool = true
var _visible: bool = false


func show_victory(winner: String, score: String, draw: bool, black_wins: bool) -> void:
	winner_text = winner
	score_text = score
	is_draw = draw
	winner_is_black = black_wins
	_visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()


func hide_victory() -> void:
	_visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if _visible and event is InputEventMouseButton and event.pressed:
		hide_victory()


func _draw() -> void:
	if not _visible:
		return

	# Full overlay
	draw_rect(Rect2(Vector2.ZERO, size), OVERLAY_COLOR)

	var center := size / 2.0
	var medal_radius := minf(size.x, size.y) * 0.12

	if not is_draw:
		_draw_ribbon(center, medal_radius)
		_draw_medal(center, medal_radius)

	_draw_text(center, medal_radius)


func _draw_ribbon(center: Vector2, radius: float) -> void:
	var ribbon_top := center.y - radius * 2.2
	var ribbon_width := radius * 0.45

	# Left ribbon tail
	var left_pts := PackedVector2Array([
		Vector2(center.x - ribbon_width, ribbon_top),
		Vector2(center.x - ribbon_width * 2.2, center.y + radius * 1.6),
		Vector2(center.x - ribbon_width * 1.4, center.y + radius * 1.2),
		Vector2(center.x - ribbon_width * 0.4, center.y + radius * 1.8),
		Vector2(center.x, center.y - radius * 0.3),
	])
	draw_colored_polygon(left_pts, RIBBON_RED)

	# Right ribbon tail
	var right_pts := PackedVector2Array([
		Vector2(center.x + ribbon_width, ribbon_top),
		Vector2(center.x + ribbon_width * 2.2, center.y + radius * 1.6),
		Vector2(center.x + ribbon_width * 1.4, center.y + radius * 1.2),
		Vector2(center.x + ribbon_width * 0.4, center.y + radius * 1.8),
		Vector2(center.x, center.y - radius * 0.3),
	])
	draw_colored_polygon(right_pts, RIBBON_DARK)

	# Ribbon neck straps
	var strap_width := radius * 0.22
	draw_rect(Rect2(
		Vector2(center.x - strap_width - radius * 0.1, ribbon_top),
		Vector2(strap_width, center.y - ribbon_top - radius * 0.6)
	), RIBBON_RED)
	draw_rect(Rect2(
		Vector2(center.x + radius * 0.1, ribbon_top),
		Vector2(strap_width, center.y - ribbon_top - radius * 0.6)
	), RIBBON_DARK)


func _draw_medal(center: Vector2, radius: float) -> void:
	var medal_color := GOLD
	var medal_dark := GOLD_DARK
	var medal_light := GOLD_LIGHT

	# Medal outer ring shadow
	draw_circle(center + Vector2(2, 3), radius * 1.05, Color(0.0, 0.0, 0.0, 0.4))

	# Medal outer ring
	draw_circle(center, radius * 1.05, medal_dark)
	draw_circle(center, radius, medal_color)

	# Inner circle border
	draw_circle(center, radius * 0.82, medal_dark)
	draw_circle(center, radius * 0.78, medal_color)

	# Star in center
	_draw_star(center, radius * 0.55, medal_light, medal_dark)

	# Rim highlight
	draw_arc(center, radius * 0.95, deg_to_rad(200), deg_to_rad(340), 24, medal_light, 2.0)


func _draw_star(center: Vector2, radius: float, color: Color, outline_color: Color) -> void:
	var points := PackedVector2Array()
	var inner_radius := radius * 0.4
	for i in range(10):
		var angle := deg_to_rad(-90 + i * 36.0)
		var r := radius if i % 2 == 0 else inner_radius
		points.append(center + Vector2(cos(angle), sin(angle)) * r)

	# Star shadow
	var shadow_points := PackedVector2Array()
	for p in points:
		shadow_points.append(p + Vector2(1, 2))
	draw_colored_polygon(shadow_points, outline_color)

	draw_colored_polygon(points, color)


func _draw_text(center: Vector2, medal_radius: float) -> void:
	var font := ThemeDB.fallback_font
	if font == null:
		return

	# Winner text above medal
	var title_size := minf(size.x, size.y) * 0.08
	var title_y := center.y - medal_radius * 2.8
	var title_width := font.get_string_size(winner_text, HORIZONTAL_ALIGNMENT_CENTER, -1, int(title_size)).x

	# Text shadow
	draw_string(font,
		Vector2((size.x - title_width) / 2.0 + 2, title_y + 2),
		winner_text, HORIZONTAL_ALIGNMENT_CENTER, -1, int(title_size),
		Color(0.0, 0.0, 0.0, 0.7))

	# Main text
	var text_color := Color(1.0, 1.0, 1.0)
	draw_string(font,
		Vector2((size.x - title_width) / 2.0, title_y),
		winner_text, HORIZONTAL_ALIGNMENT_CENTER, -1, int(title_size),
		text_color)

	# Score text below medal
	var score_size := minf(size.x, size.y) * 0.05
	var score_y := center.y + medal_radius * 2.5
	var score_width := font.get_string_size(score_text, HORIZONTAL_ALIGNMENT_CENTER, -1, int(score_size)).x

	draw_string(font,
		Vector2((size.x - score_width) / 2.0 + 1, score_y + 1),
		score_text, HORIZONTAL_ALIGNMENT_CENTER, -1, int(score_size),
		Color(0.0, 0.0, 0.0, 0.5))
	draw_string(font,
		Vector2((size.x - score_width) / 2.0, score_y),
		score_text, HORIZONTAL_ALIGNMENT_CENTER, -1, int(score_size),
		GOLD_LIGHT)

	# Continue prompt
	var hint := "Click anywhere to continue"
	var hint_size := minf(size.x, size.y) * 0.03
	var hint_w := font.get_string_size(hint, HORIZONTAL_ALIGNMENT_CENTER, -1, int(hint_size)).x
	draw_string(font,
		Vector2((size.x - hint_w) / 2.0, size.y - hint_size * 2.0),
		hint, HORIZONTAL_ALIGNMENT_CENTER, -1, int(hint_size),
		Color(1.0, 1.0, 1.0, 0.5))
