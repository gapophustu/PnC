extends Node2D

const id = "menu"
const item_number = 8
const load_game_file = "./LoadMenu.tscn"
const input_settings_file = "./InputSettings.tscn"
const sound_settings_file = "./SoundSettings.tscn"
const display_settings_file = "./DisplaySettings.tscn"
const button_file = "./Button.tscn"

var open = true
var load_game_load = preload(load_game_file)
var input_settings_load = preload(input_settings_file)
var sound_settings_load = preload(sound_settings_file)
var display_settings_load = preload(display_settings_file)
var button_load = preload(button_file)

var continue_button = button_load.instance()
var new_game = button_load.instance()
var load_game = button_load.instance()
var save_game = button_load.instance()
var input_settings = button_load.instance()
var display_settings = button_load.instance()
var sound_settings = button_load.instance()
var quit = button_load.instance()

func _ready():
	add_to_group("resizes")
	add_to_group("inputable")
	add_to_group("interactables")
	set_physics_process(true)
	z_index = 400
	var color = Color(0, 0, 0, 0.8)
	var style = StyleBoxFlat.new()
	$Background.add_stylebox_override("panel", style)
	style.set_bg_color(color)
	
	continue_button.id = "Continue"
	continue_button.text_id = "MENU_CONTINUE"
	continue_button.z_index = z_index + 1
	continue_button.connect("clicked", self, "_on_continue_pressed")
	add_child(continue_button)
	new_game.id = "New_Game"
	new_game.text_id = "MENU_NEW_GAME"
	new_game.z_index = z_index + 1
	new_game.connect("clicked", self, "_on_new_game_pressed")
	add_child(new_game)
	load_game.id = "Load_Game"
	load_game.text_id = "MENU_LOAD_GAME"
	load_game.z_index = z_index + 1
	load_game.connect("clicked", self, "_on_load_game_pressed")
	add_child(load_game)
	save_game.id = "Save Game"
	save_game.text_id = "MENU_SAVE_GAME"
	save_game.disabled = true
	save_game.z_index = z_index + 1
	save_game.connect("clicked", self, "_on_save_game_pressed")
	add_child(save_game)
	input_settings.id = "Input_Menu"
	input_settings.text_id = "MENU_INPUT"
	input_settings.z_index = z_index + 1
	input_settings.connect("clicked", self, "_on_input_settings_pressed")
	add_child(input_settings)
	display_settings.id = "Display_Menu"
	display_settings.text_id = "MENU_DISPLAY"
	display_settings.z_index = z_index + 1
	display_settings.connect("clicked", self, "_on_display_settings_pressed")
	add_child(display_settings)
	sound_settings.id = "Sound_Menu"
	sound_settings.text_id = "MENU_SOUND"
	sound_settings.z_index = z_index + 1
	sound_settings.connect("clicked", self, "_on_sound_settings_pressed")
	add_child(sound_settings)
	quit.id = "Quit"
	quit.text_id = "MENU_QUIT"
	quit.z_index = z_index + 1
	quit.connect("clicked", self, "_on_quit_pressed")
	add_child(quit)
	
	global.resize()

func input(actions):
	if global.which_input[0] == id || global.which_input[1] == z_index + 1:
		if actions.has("watch"):
			_on_continue_pressed()

func resize():
	var window_size = OS.get_window_size()
	$Background.rect_size = window_size
	if position != Vector2(0, 0):
		position = window_size
	var item_width = window_size.x * 0.8
	var item_height = window_size.y * 0.8 / item_number
	var item_pos_x = window_size.x * 0.1
	continue_button.size.x = item_width
	continue_button.size.y = item_height
	continue_button.rect_position.x = item_pos_x
	continue_button.rect_position.y = window_size.y * 0.1 + item_height * 0
	continue_button.update()
	new_game.size.x = item_width
	new_game.size.y = item_height
	new_game.rect_position.x = item_pos_x
	new_game.rect_position.y = window_size.y * 0.1 + item_height * 1
	new_game.update()
	load_game.size.x = item_width
	load_game.size.y = item_height
	load_game.rect_position.x = item_pos_x
	load_game.rect_position.y = window_size.y * 0.1 + item_height * 2
	load_game.update()
	save_game.size.x = item_width
	save_game.size.y = item_height
	save_game.rect_position.x = item_pos_x
	save_game.rect_position.y = window_size.y * 0.1 + item_height * 3
	save_game.update()
	input_settings.size.x = item_width
	input_settings.size.y = item_height
	input_settings.rect_position.x = item_pos_x
	input_settings.rect_position.y = window_size.y * 0.1 + item_height * 4
	input_settings.update()
	display_settings.size.x = item_width
	display_settings.size.y = item_height
	display_settings.rect_position.x = item_pos_x
	display_settings.rect_position.y = window_size.y * 0.1 + item_height * 5
	display_settings.update()
	sound_settings.size.x = item_width
	sound_settings.size.y = item_height
	sound_settings.rect_position.x = item_pos_x
	sound_settings.rect_position.y = window_size.y * 0.1 + item_height * 6
	sound_settings.update()
	quit.size.x = item_width
	quit.size.y = item_height
	quit.rect_position.x = item_pos_x
	quit.rect_position.y = window_size.y * 0.1 + item_height * 7
	quit.update()

func _physics_process(delta):
	place_menu()

func place_menu():
	if open && modulate.a < 1:
		modulate.a += 0.03
		modulate.a = min(modulate.a, 1)
		if modulate.a > 0 && position != Vector2(0, 0):
			position = Vector2(0, 0)
			get_tree().call_group("pausables", "pause", true)
	elif ! open && modulate.a > 0:
		modulate.a -= 0.03
		modulate.a = max(modulate.a, 0)
		if modulate.a == 0:
			position = OS.get_window_size()
			global.check_input()
			get_tree().call_group("pausables", "pause", false)

func _on_continue_pressed():
	if global.scene_id == "":
		global.load_game_state(global.save_path)
	global.menu.open = false


func _on_new_game_pressed():
	global.load_game_state("")
	global.menu.open = false


func _on_load_game_pressed():
	var load_game = load_game_load.instance()
	call_deferred("add_child", load_game)


func _on_save_game_pressed():
	var date = OS.get_datetime()
	var path = "user://" + global.save_dir + "/" + "%0*d" % [4, date.year] + "-" + "%0*d" % [2, date.month] + "-" + "%0*d" % [2, date.day] + "-" + "%0*d" % [2, date.hour] + "-" + "%0*d" % [2, date.minute] + "-" + "%0*d" % [2, date.second]
	global.save_game_state(path)
	save_game.disabled = true


func _on_input_settings_pressed():
	var input_settings = input_settings_load.instance()
	call_deferred("add_child", input_settings)


func _on_display_settings_pressed():
	var display_settings = display_settings_load.instance()
	call_deferred("add_child", display_settings)


func _on_sound_settings_pressed():
	var sound_settings = sound_settings_load.instance()
	call_deferred("add_child", sound_settings)

func _on_quit_pressed():
	get_tree().quit()

func check_inside():
	var index = -1
	if open:
		index = z_index
	return [id, index]
