extends Node2D

const id ="sond_settings_menu"
const button_file = "./Button.tscn"
const slider_file = "./Slider.tscn"

var button_load = preload(button_file)
var slider_load = preload(slider_file)

var lang_vol = slider_load.instance()
var music_vol = slider_load.instance()
var back_vol = slider_load.instance()
var video_vol = slider_load.instance()
var master_vol = slider_load.instance()
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
	language.id = "language"
	language.text_id = "MENU_SOUND_LANGUAGE"
	language.text_trailing = ": " + global.languages_sound[global.config.lang_sound]
	language.z_index = z_index + 1
	language.connect("clicked", self, "_on_language_pressed")
	add_child(language)
	lang_vol.id = "lang_vol"
	lang_vol.text_id = "MENU_SOUND_LANGUAGE_VOLUME"
	lang_vol.z_index = z_index + 1
	lang_vol.text_trailing = "%"
	lang_vol.value_range = [0, 100]
	lang_vol.value = round(global.config.volume_language * 100)
	lang_vol.connect("changed", self, "_on_changed")
	add_child(lang_vol)
	music_vol.id = "music_vol"
	music_vol.text_id = "MENU_SOUND_MUSIC"
	music_vol.z_index = z_index + 1
	music_vol.text_trailing = "%"
	music_vol.value_range = [0, 100]
	music_vol.value = round(global.config.volume_music * 100)
	music_vol.connect("changed", self, "_on_changed")
	add_child(music_vol)
	back_vol.id = "back_vol"
	back_vol.text_id = "MENU_SOUND_BACKGROUND"
	back_vol.z_index = z_index + 1
	back_vol.text_trailing = "%"
	back_vol.value_range = [0, 100]
	back_vol.value = round(global.config.volume_background * 100)
	back_vol.connect("changed", self, "_on_changed")
	add_child(back_vol)
	video_vol.id = "video_vol"
	video_vol.text_id = "MENU_SOUND_VIDEO"
	video_vol.z_index = z_index + 1
	video_vol.text_trailing = "%"
	video_vol.value_range = [0, 100]
	video_vol.value = round(global.config.volume_video * 100)
	video_vol.connect("changed", self, "_on_changed")
	add_child(video_vol)
	master_vol.id = "master_vol"
	master_vol.text_id = "MENU_SOUND_MASTER"
	master_vol.z_index = z_index + 1
	master_vol.text_trailing = "%"
	master_vol.value_range = [0, 200]
	master_vol.value = round(global.config.volume_master * 100)
	master_vol.connect("changed", self, "_on_changed")
	add_child(master_vol)
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
	language.size.x = item_width
	language.size.y = item_height
	language.rect_position.x = item_pos_x
	language.rect_position.y = window_size.y * 0.1 + item_height * 0
	language.update()
	lang_vol.size.x = item_width
	lang_vol.size.y = item_height
	lang_vol.rect_position.x = item_pos_x
	lang_vol.rect_position.y = window_size.y * 0.2
	lang_vol.update()
	music_vol.size.x = item_width
	music_vol.size.y = item_height
	music_vol.rect_position.x = item_pos_x
	music_vol.rect_position.y = window_size.y * 0.3
	music_vol.update()
	back_vol.size.x = item_width
	back_vol.size.y = item_height
	back_vol.rect_position.x = item_pos_x
	back_vol.rect_position.y = window_size.y * 0.4
	back_vol.update()
	video_vol.size.x = item_width
	video_vol.size.y = item_height
	video_vol.rect_position.x = item_pos_x
	video_vol.rect_position.y = window_size.y * 0.5
	video_vol.update()
	master_vol.size.x = item_width
	master_vol.size.y = item_height
	master_vol.rect_position.x = item_pos_x
	master_vol.rect_position.y = window_size.y * 0.6
	master_vol.update()
	back.size.x = item_width
	back.size.y = item_height
	back.rect_position.x = item_pos_x
	back.rect_position.y = window_size.y * 0.1 + item_height * 7
	back.update()

func _on_back_pressed():
	queue_free()

func _on_changed(value = 0):
	global.config.volume_language = lang_vol.value / 100
	global.config.volume_music = music_vol.value / 100
	global.config.volume_background = back_vol.value / 100
	global.config.volume_video = video_vol.value / 100
	global.config.volume_master = master_vol.value / 100
	global.write_config()
	global.calculate_volumes()

func _on_language_pressed():
	var languages = global.languages_sound.keys()
	var index = languages.find(global.config.lang_sound)
	if index + 1 == languages.size():
		index = 0
	else:
		index += 1
	language.text_trailing = ": " + global.languages_sound[languages[index]]
	resize()
	global.config.lang_sound = languages[index]
	_on_changed()

func check_inside():
	var index = -1
	if get_parent().open:
		index = z_index
	return [id, index]
