class_name ColorSettings
extends RefCounted

signal colors_changed

const SAVE_PATH := "user://color_settings.json"

var board_color := Color(0.92, 0.92, 0.90)
var token1_color := Color(0.12, 0.12, 0.12)
var token2_color := Color(1.0, 0.2, 0.55)

const PRESETS := {
	"Black & Pink": {
		"board": Color(0.92, 0.92, 0.90),
		"token1": Color(0.12, 0.12, 0.12),
		"token2": Color(1.0, 0.2, 0.55),
	},
	"Classic": {
		"board": Color(0.08, 0.44, 0.15),
		"token1": Color(0.12, 0.12, 0.12),
		"token2": Color(0.92, 0.92, 0.90),
	},
	"Ocean": {
		"board": Color(0.1, 0.25, 0.45),
		"token1": Color(0.95, 0.95, 0.90),
		"token2": Color(0.2, 0.75, 0.85),
	},
	"Midnight": {
		"board": Color(0.12, 0.12, 0.18),
		"token1": Color(0.85, 0.85, 0.90),
		"token2": Color(0.6, 0.2, 0.8),
	},
	"Sunset": {
		"board": Color(0.95, 0.85, 0.7),
		"token1": Color(0.2, 0.15, 0.1),
		"token2": Color(0.95, 0.4, 0.15),
	},
	"Forest": {
		"board": Color(0.18, 0.3, 0.15),
		"token1": Color(0.9, 0.85, 0.7),
		"token2": Color(0.55, 0.8, 0.25),
	},
}


func _init() -> void:
	load_settings()


func apply_preset(preset_name: String) -> void:
	var preset: Dictionary = PRESETS.get(preset_name, PRESETS["Classic"])
	board_color = preset.board
	token1_color = preset.token1
	token2_color = preset.token2
	colors_changed.emit()
	save_settings()


func set_board_color(color: Color) -> void:
	board_color = color
	colors_changed.emit()
	save_settings()


func set_token1_color(color: Color) -> void:
	token1_color = color
	colors_changed.emit()
	save_settings()


func set_token2_color(color: Color) -> void:
	token2_color = color
	colors_changed.emit()
	save_settings()


# Derive related colors from the base colors
func get_board_light() -> Color:
	return board_color.lightened(0.05)

func get_line_color() -> Color:
	var luminance := board_color.get_luminance()
	if luminance > 0.5:
		return board_color.darkened(0.25)
	else:
		return board_color.lightened(0.25)

func get_frame_color() -> Color:
	return board_color.darkened(0.15)

func get_frame_light() -> Color:
	return board_color.darkened(0.05)

func get_frame_dark() -> Color:
	return board_color.darkened(0.3)

func get_highlight_color() -> Color:
	var luminance := board_color.get_luminance()
	if luminance > 0.5:
		return Color(0.4, 0.4, 0.4, 0.35)
	else:
		return Color(0.7, 0.7, 0.7, 0.35)

func get_token_highlight(base: Color) -> Color:
	return base.lightened(0.3)

func get_token_shadow(base: Color) -> Color:
	return base.darkened(0.4)


func save_settings() -> void:
	var data := {
		"board": _color_to_hex(board_color),
		"token1": _color_to_hex(token1_color),
		"token2": _color_to_hex(token2_color),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))


func load_settings() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var data: Dictionary = json.data
			board_color = Color.from_string(data.get("board", ""), board_color)
			token1_color = Color.from_string(data.get("token1", ""), token1_color)
			token2_color = Color.from_string(data.get("token2", ""), token2_color)


func _color_to_hex(c: Color) -> String:
	return c.to_html(false)
