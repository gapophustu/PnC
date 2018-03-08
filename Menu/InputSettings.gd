extends Node2D

const id ="input_settings_menu"
const button_file = "./Button.tscn"
const slider_file = "./Slider.tscn"

var button_load = preload(button_file)
var slider_load = preload(slider_file)

var skip_delay = slider_load.instance()
var cursor_speed = slider_load.instance()
var input_type = button_load.instance()
var camera_mode = button_load.instance()
var back = button_load.instance()

func _ready():
	add_to_group("resizes")
	add_to_group("inputable")
	add_to_group("interactables")
	var color = Color(0, 0, 0, 0.8)
	var style = StyleBoxFlat.new()
	z_index = 500
	$Background.add_stylebox_override("panel", style)
	style.set_bg_color(color)
	input_type.id = "input_type"
	input_type.text_id = "MENU_INPUT_TYPE"
	if global.config.input_type == "one_click":
		input_type.text_trailing = ": " + TranslationServer.translate("MENU_INPUT_TYPE_ONE_CLICK")
	else:
		input_type.text_trailing = ": " + TranslationServer.translate("MENU_INPUT_TYPE_MOUSE")
	input_type.z_index = z_index + 1
	input_type.connect("clicked", self, "_on_input_type_pressed")
	add_child(input_type)
	camera_mode.id = "camera_mode"
	camera_mode.text_id = "MENU_INPUT_CAMERA_MODE"
	if global.config.camera_mode == "scroll":
		camera_mode.text_trailing = ": " + TranslationServer.translate("MENU_INPUT_CAMERA_MODE_SCROLL")
	elif global.config.camera_mode == "follow_cursor":
		camera_mode.text_trailing = ": " + TranslationServer.translate("MENU_INPUT_CAMERA_MODE_FOLLOW_CURSOR")
	elif global.config.camera_mode == "follow_character":
		camera_mode.text_trailing = ": " + TranslationServer.translate("MENU_INPUT_CAMERA_MODE_FOLLOW_CHARACTER")
	camera_mode.z_index = z_index + 1
	camera_mode.connect("clicked", self, "_on_camera_mode_pressed")
	add_child(camera_mode)
	skip_delay.id = "skip_delay"
	skip_delay.text_id = "MENU_INPUT_SKIP_DELAY"
	skip_delay.z_index = z_index + 1
	skip_delay.text_trailing = "ms"
	skip_delay.value_range = [0, 1000]
	skip_delay.value = global.config.skip_delay
	skip_delay.connect("changed", self, "_on_changed")
	add_child(skip_delay)
	cursor_speed.id = "cursor_speed"
	cursor_speed.text_id = "MENU_INPUT_CURSOR_SPEED"
	cursor_speed.z_index = z_index + 1
	cursor_speed.value_range = [3, 300]
	cursor_speed.value = global.config.cursor_speed
	cursor_speed.connect("changed", self, "_on_changed")
	add_child(cursor_speed)
	back.id = "Back"
	back.text_id = "MENU_BACK"
	back.z_index = z_index + 1
	back.connect("clicked", self, "_on_back_pressed")
	add_child(back)
	resize()

func input(actions):
	if global.which_input[0] == id || global.which_input[1] == z_index + 1:
		if actions.has("watch"):
			_on_back_pressed()

func resize():
	var window_size = OS.get_window_size()
	$Background.rect_size = window_size
	var item_width = window_size.x * 0.8
	var item_height = window_size.y * 0.8 / 8
	var item_pos_x = window_size.x * 0.1
	input_type.size.x = item_width
	input_type.size.y = item_height
	input_type.rect_position.x = item_pos_x
	input_type.rect_position.y = window_size.y * 0.1 + item_height * 0
	input_type.update()
	camera_mode.size.x = item_width
	camera_mode.size.y = item_height
	camera_mode.rect_position.x = item_pos_x
	camera_mode.rect_position.y = window_size.y * 0.1 + item_height * 1
	camera_mode.update()
	skip_delay.size.x = item_width
	skip_delay.size.y = item_height
	skip_delay.rect_position.x = item_pos_x
	skip_delay.rect_position.y = window_size.y * 0.1 + item_height * 2
	skip_delay.update()
	cursor_speed.size.x = item_width
	cursor_speed.size.y = item_height
	cursor_speed.rect_position.x = item_pos_x
	cursor_speed.rect_position.y = window_size.y * 0.1 + item_height * 3
	cursor_speed.update()
	back.size.x = item_width
	back.size.y = item_height
	back.rect_position.x = item_pos_x
	back.rect_position.y = window_size.y * 0.1 + item_height * 7
	back.update()

func _on_back_pressed():
	queue_free()

func _on_changed(value = 0):
	global.config.skip_delay = skip_delay.value
	global.config.cursor_speed = cursor_speed.value
	global.write_config()

func _on_input_type_pressed():
	var input_types = global.input_types
	var index = input_types.find(global.config.input_type)
	if index + 1 == input_types.size():
		index = 0
	else:
		index += 1
	global.config.input_type = input_types[index]
	if global.config.input_type == "one_click":
		input_type.text_trailing = ": " + TranslationServer.translate("MENU_INPUT_TYPE_ONE_CLICK")
	else:
		input_type.text_trailing = ": " + TranslationServer.translate("MENU_INPUT_TYPE_MOUSE")
	input_type.update()
	_on_changed()

func _on_camera_mode_pressed():
	var camera_modes = global.camera_modes
	var index = camera_modes.find(global.config.camera_mode)
	if index + 1 == camera_modes.size():
		index = 0
	else:
		index += 1
	global.config.camera_mode = camera_modes[index]
	if global.config.camera_mode == "scroll":
		camera_mode.text_trailing = ": " + TranslationServer.translate("MENU_INPUT_CAMERA_MODE_SCROLL")
	elif global.config.camera_mode == "follow_cursor":
		camera_mode.text_trailing = ": " + TranslationServer.translate("MENU_INPUT_CAMERA_MODE_FOLLOW_CURSOR")
	elif global.config.camera_mode == "follow_character":
		camera_mode.text_trailing = ": " + TranslationServer.translate("MENU_INPUT_CAMERA_MODE_FOLLOW_CHARACTER")
	camera_mode.update()
	_on_changed()

func check_inside():
	var index = -1
	if get_parent().open:
		index = z_index
	return [id, index]
