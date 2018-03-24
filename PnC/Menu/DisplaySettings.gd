extends Node2D

const id = "display_settings_menu"
const button_file = "./Button.tscn"
const slider_file = "./Slider.tscn"
const checkbox_file = "./Checkbox.tscn"

var button_load = preload(button_file)
var slider_load = preload(slider_file)
var checkbox_load = preload(checkbox_file)

var scale_button = slider_load.instance()
var text_size = slider_load.instance()
var fullscreen = checkbox_load.instance()
var subtitles = checkbox_load.instance()
var highlight = checkbox_load.instance()
var resolution = button_load.instance()
var language = button_load.instance()
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
	resolution.id = "resolution"
	resolution.text_id = "MENU_WINDOW_RESOLUTION"
	resolution.text_trailing = ": " + str(Vector2(global.config.resolution_x, global.config.resolution_y))
	resolution.z_index = z_index + 1
	resolution.connect("clicked", self, "_on_resolution_pressed")
	add_child(resolution)
	language.id = "language"
	language.text_id = "MENU_TEXT_LANGUAGE"
	language.text_trailing = ": " + global.languages_text[global.config.lang_text]
	language.z_index = z_index + 1
	language.connect("clicked", self, "_on_language_pressed")
	add_child(language)
	back.id = "Back"
	back.text_id = "MENU_BACK"
	back.z_index = z_index + 1
	back.connect("clicked", self, "_on_back_pressed")
	add_child(back)
	scale_button.id = "Scale"
	scale_button.text_id = "MENU_DISPLAY_SCALE"
	scale_button.z_index = z_index + 1
	scale_button.text_trailing = "%"
	scale_button.value_range = [50, 200]
	scale_button.value = round(global.config.scale * 100)
	scale_button.connect("changed", self, "_on_changed")
	add_child(scale_button)
	text_size.id = "text_size"
	text_size.text_id = "MENU_TEXT_SIZE"
	text_size.z_index = z_index + 1
	text_size.text_trailing = ""
	text_size.value_range = [5, 100]
	text_size.value = round(global.config.text_size)
	text_size.connect("changed", self, "_on_changed")
	add_child(text_size)
	fullscreen.id = "fullscreen"
	fullscreen.text_id = "MENU_FULLSCREEN"
	fullscreen.z_index = z_index + 1
	fullscreen.checked = global.config.fullscreen
	fullscreen.connect("changed", self, "_on_fullscreen_pressed")
	add_child(fullscreen)
	subtitles.id = "subtitles"
	subtitles.text_id = "MENU_SUBTITLES"
	subtitles.z_index = z_index + 1
	subtitles.checked = global.config.subtitles
	subtitles.connect("changed", self, "_on_changed")
	add_child(subtitles)
	highlight.id = "highlight"
	highlight.text_id = "MENU_HIGHLIGHT"
	highlight.z_index = z_index + 1
	highlight.checked = global.config.highlight
	highlight.connect("changed", self, "_on_changed")
	add_child(highlight)
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
	scale_button.size.x = item_width
	scale_button.size.y = item_height
	scale_button.rect_position.x = item_pos_x
	scale_button.rect_position.y = window_size.y * 0.1
	scale_button.update()
	fullscreen.size.x = item_width
	fullscreen.size.y = item_height
	fullscreen.rect_position.x = item_pos_x
	fullscreen.rect_position.y = window_size.y * 0.2
	fullscreen.update()
	resolution.size.x = item_width
	resolution.size.y = item_height
	resolution.rect_position.x = item_pos_x
	resolution.rect_position.y = window_size.y * 0.1 + item_height * 2
	resolution.update()
	language.size.x = item_width
	language.size.y = item_height
	language.rect_position.x = item_pos_x
	language.rect_position.y = window_size.y * 0.1 + item_height * 3
	language.update()
	subtitles.size.x = item_width
	subtitles.size.y = item_height
	subtitles.rect_position.x = item_pos_x
	subtitles.rect_position.y = window_size.y * 0.1 + item_height * 4
	subtitles.update()
	text_size.size.x = item_width
	text_size.size.y = item_height
	text_size.rect_position.x = item_pos_x
	text_size.rect_position.y = window_size.y * 0.1 + item_height * 5
	text_size.update()
	highlight.size.x = item_width
	highlight.size.y = item_height
	highlight.rect_position.x = item_pos_x
	highlight.rect_position.y = window_size.y * 0.1 + item_height * 6
	highlight.update()
	back.size.x = item_width
	back.size.y = item_height
	back.rect_position.x = item_pos_x
	back.rect_position.y = window_size.y * 0.1 + item_height * 7
	back.update()

func _on_back_pressed():
	global.resize()
	queue_free()

func _on_changed(value = 0):
	global.config.scale = scale_button.value / 100
	global.config.subtitles = subtitles.checked
	global.config.highlight = highlight.checked
	global.config.text_size = text_size.value
	global.write_config()
	global.resize()

func _on_resolution_pressed():
	var index = global.resolutions.find(Vector2(global.config.resolution_x, global.config.resolution_y))
	if index + 1 == global.resolutions.size():
		index = 0
	else:
		index += 1
	global.config.resolution_x = global.resolutions[index].x
	global.config.resolution_y = global.resolutions[index].y
	resolution.text_trailing = ": " + str(global.resolutions[index])
	global.resize()

func _on_fullscreen_pressed():
	global.config.fullscreen = ! global.config.fullscreen
	global.write_config()
	global.resize()
	fullscreen.checked = global.config.fullscreen

func _on_language_pressed():
	var languages = global.languages_text.keys()
	var index = languages.find(global.config.lang_text)
	if index + 1 == languages.size():
		index = 0
	else:
		index += 1
	language.text_trailing = ": " + global.languages_text[languages[index]]
	global.config.lang_text = languages[index]
	global._on_switch_locale()
	_on_changed()

func check_inside():
	var index = -1
	if get_parent().open:
		index = z_index
	return [id, index]
