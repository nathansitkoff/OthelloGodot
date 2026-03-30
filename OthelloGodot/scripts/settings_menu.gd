extends Control

const OVERLAY_BG := Color(0.1, 0.1, 0.12, 0.92)
const HEADER_COLOR := Color(1.0, 1.0, 1.0)
const TEXT_COLOR := Color(0.85, 0.85, 0.85)
const DIM_TEXT := Color(0.5, 0.5, 0.5)
const PANEL_BG := Color(0.18, 0.18, 0.20)
const PANEL_BORDER := Color(0.3, 0.3, 0.32)
const SWATCH_BORDER := Color(0.5, 0.5, 0.5)
const SWATCH_SELECTED := Color(1.0, 1.0, 1.0)

var color_settings: ColorSettings
var _visible_state: bool = false
var _picker_nodes: Array = []
var _preset_buttons: Array = []
var _container: VBoxContainer


func show_menu(settings: ColorSettings) -> void:
	color_settings = settings
	_visible_state = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	visible = true


func hide_menu() -> void:
	_visible_state = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_clear_ui()


func _clear_ui() -> void:
	for child in get_children():
		child.queue_free()
	_picker_nodes.clear()
	_preset_buttons.clear()
	_container = null


func _build_ui() -> void:
	_clear_ui()

	# Background panel
	var bg := ColorRect.new()
	bg.color = OVERLAY_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Centered panel
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(380, 460)
	panel.position = Vector2(-190, -230)
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_BG
	style.border_color = PANEL_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(20)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	_container = VBoxContainer.new()
	_container.add_theme_constant_override("separation", 14)
	panel.add_child(_container)

	# Header
	var header := HBoxContainer.new()
	_container.add_child(header)
	var title := Label.new()
	title.text = "Settings"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", HEADER_COLOR)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.pressed.connect(hide_menu)
	header.add_child(close_btn)

	# Separator
	var sep := HSeparator.new()
	_container.add_child(sep)

	# Presets section
	var preset_label := Label.new()
	preset_label.text = "Presets"
	preset_label.add_theme_font_size_override("font_size", 16)
	preset_label.add_theme_color_override("font_color", TEXT_COLOR)
	_container.add_child(preset_label)

	var preset_grid := GridContainer.new()
	preset_grid.columns = 3
	preset_grid.add_theme_constant_override("h_separation", 8)
	preset_grid.add_theme_constant_override("v_separation", 8)
	_container.add_child(preset_grid)

	for preset_name in ColorSettings.PRESETS:
		var btn := Button.new()
		btn.text = preset_name
		btn.custom_minimum_size = Vector2(105, 30)
		btn.pressed.connect(_on_preset_selected.bind(preset_name))
		preset_grid.add_child(btn)

	# Separator
	var sep2 := HSeparator.new()
	_container.add_child(sep2)

	# Custom colors section
	var custom_label := Label.new()
	custom_label.text = "Custom Colors"
	custom_label.add_theme_font_size_override("font_size", 16)
	custom_label.add_theme_color_override("font_color", TEXT_COLOR)
	_container.add_child(custom_label)

	_add_color_row("Board", color_settings.board_color, _on_board_color_changed)
	_add_color_row("Token 1", color_settings.token1_color, _on_token1_color_changed)
	_add_color_row("Token 2", color_settings.token2_color, _on_token2_color_changed)


func _add_color_row(label_text: String, current_color: Color, callback: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_container.add_child(row)

	var label := Label.new()
	label.text = label_text
	label.add_theme_color_override("font_color", TEXT_COLOR)
	label.custom_minimum_size = Vector2(80, 0)
	row.add_child(label)

	var picker := ColorPickerButton.new()
	picker.color = current_color
	picker.custom_minimum_size = Vector2(50, 30)
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	picker.color_changed.connect(callback)
	picker.edit_alpha = false
	row.add_child(picker)
	_picker_nodes.append(picker)


func _on_preset_selected(preset_name: String) -> void:
	color_settings.apply_preset(preset_name)
	# Update picker buttons to reflect preset colors
	if _picker_nodes.size() >= 3:
		_picker_nodes[0].color = color_settings.board_color
		_picker_nodes[1].color = color_settings.token1_color
		_picker_nodes[2].color = color_settings.token2_color


func _on_board_color_changed(color: Color) -> void:
	color_settings.set_board_color(color)


func _on_token1_color_changed(color: Color) -> void:
	color_settings.set_token1_color(color)


func _on_token2_color_changed(color: Color) -> void:
	color_settings.set_token2_color(color)
