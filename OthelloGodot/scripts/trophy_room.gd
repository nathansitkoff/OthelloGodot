extends Control

const OVERLAY_BG := Color(0.12, 0.08, 0.05, 0.92)
const HEADER_COLOR := Color(1.0, 0.84, 0.0)
const TEXT_COLOR := Color(0.9, 0.9, 0.88)
const DIM_TEXT := Color(0.6, 0.6, 0.55)
const CARD_BG := Color(0.18, 0.14, 0.10)
const CARD_BORDER := Color(0.35, 0.28, 0.18)
const EMPTY_TEXT := Color(0.5, 0.45, 0.35)

const MEDAL_COLORS := {
	"gold": {
		"base": Color(1.0, 0.84, 0.0),
		"dark": Color(0.85, 0.65, 0.0),
		"light": Color(1.0, 0.95, 0.5),
	},
	"silver": {
		"base": Color(0.75, 0.75, 0.78),
		"dark": Color(0.55, 0.55, 0.58),
		"light": Color(0.92, 0.92, 0.95),
	},
	"bronze": {
		"base": Color(0.80, 0.50, 0.20),
		"dark": Color(0.60, 0.35, 0.12),
		"light": Color(0.95, 0.70, 0.40),
	},
}

const RIBBON_RED := Color(0.7, 0.12, 0.12)
const RIBBON_DARK := Color(0.5, 0.08, 0.08)

var medal_system: MedalSystem
var _visible_state: bool = false
var scroll_offset: float = 0.0
var max_scroll: float = 0.0


func show_room(system: MedalSystem) -> void:
	medal_system = system
	_visible_state = true
	scroll_offset = 0.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()


func hide_room() -> void:
	_visible_state = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if not _visible_state:
		return
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				scroll_offset = maxf(0.0, scroll_offset - 40.0)
				queue_redraw()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				scroll_offset = minf(max_scroll, scroll_offset + 40.0)
				queue_redraw()
			elif event.button_index == MOUSE_BUTTON_LEFT:
				# Close button check
				var close_rect := Rect2(size.x * 0.75 - 10, 20, 30, 30)
				if close_rect.has_point(event.position):
					hide_room()


func _draw() -> void:
	if not _visible_state:
		return

	var font := ThemeDB.fallback_font
	if font == null:
		return

	# Background
	draw_rect(Rect2(Vector2.ZERO, size), OVERLAY_BG)

	var margin := size.x * 0.12
	var content_width := size.x - margin * 2.0
	var top := 30.0

	# Header
	var title := "TROPHY ROOM"
	var title_size := 28
	var title_w := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x
	draw_string(font, Vector2((size.x - title_w) / 2.0, top + 28), title,
		HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, HEADER_COLOR)

	# Close X button
	draw_string(font, Vector2(size.x * 0.75, top + 25), "X",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 22, DIM_TEXT)

	top += 55.0

	# Divider line
	draw_line(Vector2(margin, top), Vector2(size.x - margin, top), CARD_BORDER, 1.0)
	top += 15.0

	# Get displayable medals (filter out internal tracking entries)
	var display_medals: Array = []
	if medal_system:
		for m in medal_system.get_all_medals():
			if not str(m.id).begins_with("_"):
				display_medals.append(m)

	if display_medals.size() == 0:
		var msg := "No medals yet. Win a game to earn your first!"
		var msg_w := font.get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
		draw_string(font, Vector2((size.x - msg_w) / 2.0, size.y / 2.0),
			msg, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, EMPTY_TEXT)
		return

	# Medal grid
	var cols := 3
	var card_spacing := 12.0
	var card_w := (content_width - card_spacing * (cols - 1)) / cols
	var card_h := card_w * 1.3
	var start_y := top - scroll_offset

	for i in range(display_medals.size()):
		var medal: Dictionary = display_medals[i]
		var col := i % cols
		var row := i / cols
		var card_x := margin + col * (card_w + card_spacing)
		var card_y := start_y + row * (card_h + card_spacing)

		# Skip if off screen
		if card_y + card_h < 0 or card_y > size.y:
			continue

		_draw_medal_card(font, card_x, card_y, card_w, card_h, medal)

	# Calculate max scroll
	var total_rows := ceili(float(display_medals.size()) / cols)
	var total_height := total_rows * (card_h + card_spacing)
	max_scroll = maxf(0.0, total_height - (size.y - top - 20.0))


func _draw_medal_card(font: Font, x: float, y: float, w: float, h: float, medal: Dictionary) -> void:
	# Card background
	draw_rect(Rect2(Vector2(x, y), Vector2(w, h)), CARD_BG)
	draw_rect(Rect2(Vector2(x, y), Vector2(w, h)), CARD_BORDER, false, 1.0)

	var cx := x + w / 2.0
	var medal_radius := w * 0.18
	var medal_cy := y + h * 0.38

	var color_key: String = medal.get("color", "gold")
	var colors: Dictionary = MEDAL_COLORS.get(color_key, MEDAL_COLORS.gold)

	# Ribbon
	var ribbon_top := medal_cy - medal_radius * 1.8
	var rw := medal_radius * 0.3
	draw_rect(Rect2(Vector2(cx - rw - medal_radius * 0.08, ribbon_top),
		Vector2(rw, medal_cy - ribbon_top - medal_radius * 0.4)), RIBBON_RED)
	draw_rect(Rect2(Vector2(cx + medal_radius * 0.08, ribbon_top),
		Vector2(rw, medal_cy - ribbon_top - medal_radius * 0.4)), RIBBON_DARK)

	# Ribbon V at top
	var v_pts := PackedVector2Array([
		Vector2(cx - rw * 2.0, ribbon_top),
		Vector2(cx, ribbon_top + medal_radius * 0.5),
		Vector2(cx + rw * 2.0, ribbon_top),
		Vector2(cx + rw * 2.5, ribbon_top - medal_radius * 0.15),
		Vector2(cx, ribbon_top + medal_radius * 0.3),
		Vector2(cx - rw * 2.5, ribbon_top - medal_radius * 0.15),
	])
	draw_colored_polygon(v_pts, RIBBON_RED)

	# Medal shadow
	draw_circle(Vector2(cx + 1, medal_cy + 2), medal_radius * 1.02, Color(0, 0, 0, 0.3))

	# Medal disc
	draw_circle(Vector2(cx, medal_cy), medal_radius, colors.dark)
	draw_circle(Vector2(cx, medal_cy), medal_radius * 0.92, colors.base)

	# Inner ring
	draw_arc(Vector2(cx, medal_cy), medal_radius * 0.72, 0, TAU, 32, colors.dark, 1.5)

	# Star
	_draw_star(Vector2(cx, medal_cy), medal_radius * 0.5, colors.light, colors.dark)

	# Highlight arc
	draw_arc(Vector2(cx, medal_cy), medal_radius * 0.88, deg_to_rad(200), deg_to_rad(330), 16, colors.light, 1.5)

	# Title text
	var title_size := 13
	var title: String = medal.get("title", "")
	var tw := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x
	var title_x := x + (w - tw) / 2.0
	draw_string(font, Vector2(title_x, y + h * 0.72), title,
		HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, HEADER_COLOR)

	# Detail text
	var detail_size := 11
	var detail: String = medal.get("detail", "")
	var dw := font.get_string_size(detail, HORIZONTAL_ALIGNMENT_LEFT, -1, detail_size).x
	var detail_x := x + (w - dw) / 2.0
	draw_string(font, Vector2(detail_x, y + h * 0.83), detail,
		HORIZONTAL_ALIGNMENT_LEFT, -1, detail_size, TEXT_COLOR)

	# Date text
	var date_size := 10
	var date_str: String = medal.get("date", "")
	var datew := font.get_string_size(date_str, HORIZONTAL_ALIGNMENT_LEFT, -1, date_size).x
	var date_x := x + (w - datew) / 2.0
	draw_string(font, Vector2(date_x, y + h * 0.93), date_str,
		HORIZONTAL_ALIGNMENT_LEFT, -1, date_size, DIM_TEXT)


func _draw_star(center: Vector2, radius: float, color: Color, outline_color: Color) -> void:
	var points := PackedVector2Array()
	var inner_radius := radius * 0.4
	for i in range(10):
		var angle := deg_to_rad(-90 + i * 36.0)
		var r := radius if i % 2 == 0 else inner_radius
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	var shadow_pts := PackedVector2Array()
	for p in points:
		shadow_pts.append(p + Vector2(1, 1))
	draw_colored_polygon(shadow_pts, outline_color)
	draw_colored_polygon(points, color)
