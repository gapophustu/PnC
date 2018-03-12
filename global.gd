extends Node

const id = "global"
const config_path = "user://config.cfg"
const save_path = "user://current.save"
const menu_file = "res://Menu/Menu.tscn"
const save_dir = "save"

var config
var game_state = {}
var base
var scene_id = ""
var scene
var cursor_busy = false
var volume = {}

#list of supported input types
var input_types = ["default", "one_click"]

#list of supported camera modes
var camera_modes = ["scroll", "follow_cursor", "follow_character"]

#axis states
var axis_states = {}

# list for supported text languages
var languages_text = {
		en = "English",
		de = "Deutsch"
	}

# list for supported sound languages
var languages_sound = {
		en = "English",
		de = "Deutsch"
	}

#list of supported resolutions in windowed mode
var resolutions = [Vector2(640, 480), Vector2(960, 540), Vector2(1280, 720)]

var menu_load = preload(menu_file)
var menu = menu_load.instance()

var mouse_state = "default"
var which_input = ["menu", -2]
var highlighted = false
var highlight_progrss = 0

func _ready():
	var dir = Directory.new()
	dir.open("user://")
	dir.make_dir(save_dir)
	if TranslationServer.get_locale().begins_with("de"):
		TranslationServer.set_locale("de")
	else:
		TranslationServer.set_locale("en")
	global.load_config()
	global.calculate_volumes()
	add_to_group("game_state")
	add_to_group("inputable")
	set_physics_process(true)
	set_process_input(true)
	global.resize()

func load_config():
	var config_file = File.new()
	if ! bool(config_file.open(config_path, File.READ)):
		global.config = parse_json(config_file.get_line())
	else:
		global.config = {}
	config_file.close()
	if ! global.config.has("input_type"):
		global.config["input_type"] = "default"
	if ! global.config.has("camera_mode"):
		global.config["camera_mode"] = "scroll"
	if ! global.config.has("cursor_speed"):
		global.config["cursor_speed"] = 75
	if ! global.config.has("skip_delay"):
		global.config["skip_delay"] = 250
	if ! global.config.has("bindings"):
		global.config.bindings = {
			menu = {
				keys = ["F10"],
				joy_buttons = ["Start"]
				},
			fullscreen = {
				keys = ["F11"],
				joy_buttons = ["L"]
				},
			interact = {
				buttons = ["1"],
				keys = ["A"],
				joy_buttons = ["Face Button Bottom"]
				},
			watch = {
				buttons = ["2"],
				keys = ["W"],
				joy_buttons = ["Face Button Right"]
				},
			pause = {
				keys = ["P"],
				joy_buttons = ["R"]
				},
			highlight = {
				keys = ["Space"],
				joy_buttons = ["Face Button Top"]
				},
			toggle_inventory = {
				keys = ["I"],
				joy_buttons = ["Face Button Left"]
				},
			open_inventory = {
				buttons = ["5"],
				keys = []
				},
			close_inventory = {
				buttons = ["4"],
				keys = []
				},
			scroll_left = {
				keys = ["Left"],
				joy_buttons = ["DPAD Left"],
				axis = [["Right Stick X", -1]]
				},
			scroll_right = {
				keys = ["Right"],
				joy_buttons = ["DPAD Right"],
				axis = [["Right Stick X", 1]]
				},
			scroll_up = {
				keys = ["Up"],
				joy_buttons = ["DPAD Up"],
				axis = [["Right Stick Y", -1]]
				},
			scroll_down = {
				keys = ["Down"],
				joy_buttons = ["DPAD Down"],
				axis = [["Right Stick Y", 1]]
				},
			cursor_left = {
				axis = [["Left Stick X", -1]]
				},
			cursor_right = {
				axis = [["Left Stick X", 1]]
				},
			cursor_up = {
				axis = [["Left Stick Y", -1]]
				},
			cursor_down = {
				axis = [["Left Stick Y", 1]]
				}
			}
	if ! global.config.has("scale"):
		global.config["scale"] = 1
	if ! global.config.has("fullscreen"):
		global.config["fullscreen"] = true
	if ! global.config.has("resolution_x"):
		global.config["resolution_x"] = 640
	if ! global.config.has("resolution_y"):
		global.config["resolution_y"] = 480
	if ! global.config.has("lang_text"):
		global.config["lang_text"] = TranslationServer.get_locale()
	if ! global.config.has("subtitles"):
		global.config["subtitles"] = true
	if ! global.config.has("text_size"):
		global.config["text_size"] = 20
	if ! global.config.has("highlight"):
		global.config["highlight"] = true
	if ! global.config.has("lang_sound"):
		global.config["lang_sound"] = TranslationServer.get_locale()
	if ! global.config.has("volume_language"):
		global.config["volume_language"] = 1
	if ! global.config.has("volume_music"):
		global.config["volume_music"] = 0.5
	if ! global.config.has("volume_background"):
		global.config["volume_background"] = 0.75
	if ! global.config.has("volume_video"):
		global.config["volume_video"] = 1
	if ! global.config.has("volume_master"):
		global.config["volume_master"] = 1
	global._on_switch_locale()
	global.write_config()

func _on_switch_locale():
	TranslationServer.set_locale(global.config.lang_text)
	get_tree().call_group("translations", "_on_switch_locale")

func write_config():
	var config_file = File.new()
	if ! bool(config_file.open(config_path, File.WRITE)):
		config_file.store_line(to_json(global.config))
	config_file.close()

func load_game_state(path):
	if global.scene != null:
		global.scene.queue_free()
	global.game_state = {}
	if path != "":
		var save_game = File.new()
		if ! bool(save_game.open(path, File.READ)):
			global.game_state = parse_json(save_game.get_line())
		save_game.close()
		if global.game_state.has("global") && global.game_state.global.has("scene_id"):
			global.scene_id = global.game_state.global.scene_id
	if global.scene_id == "":
		global.scene_id = "Scene1"
		global.update_game_state()
	switch_scene()

func update_game_state():
	for i in get_tree().get_nodes_in_group("game_state"):
		global.game_state[i.id] = i.return_state()
	save_game_state()
	menu.save_game.disabled = false

func save_game_state(path = save_path):
	var save_game = File.new()
	if ! bool(save_game.open(path, File.WRITE)):
		save_game.store_line(to_json(global.game_state))
	save_game.close()

func switch_scene():
	if global.scene != null:
		global.scene.queue_free()
	var scene_load = load("res://" + global.scene_id + "/Scene.tscn")
	global.scene = scene_load.instance()
	global.base.call_deferred("add_child", global.scene)

func return_state():
	var state = {
		scene_id=scene_id
	}
	return state

func _on_startup():
	global.base.connect("size_changed", self, "resize")
	global.base.call_deferred("add_child", global.menu)

func resize():
	OS.set_window_fullscreen(global.config.fullscreen)
	if ! global.config.fullscreen:
		OS.set_window_size(Vector2(global.config.resolution_x, global.config.resolution_y))
	get_tree().call_group("resizes", "resize")

func _physics_process(delta):
	global.change_highlight()
	global.check_joy_axis()
	global.check_cursor_action()

func change_highlight():
	if global.config.highlight:
		if global.highlighted && global.highlight_progrss <= 1:
			global.highlight_progrss += 0.005
			global.highlight_progrss = min(global.highlight_progrss, 1)
			if global.highlight_progrss == 1:
				global.highlighted = false
		elif ! global.highlighted && global.highlight_progrss > 0:
			global.highlight_progrss -= 0.005
			global.highlight_progrss = max(global.highlight_progrss, 0)
	else:
		global.highlighted = false
		global.highlight_progrss = 0

func _input(event):
	check_input()
	var actions = global.check_action(event)
	if event is InputEventMouseMotion:
		actions.append("cursor_moved")
	get_tree().call_group("inputable", "input", actions)

func input(actions):
	if actions.has("menu")  && global.scene != null:
		global.menu.open = ! global.menu.open
	if actions.has("fullscreen"):
		global.config.fullscreen = ! global.config.fullscreen
		global.write_config()
		global.resize()

func check_action(event):
	var actions = []
	if event.is_pressed():
		if event is InputEventKey:
			var event_text = event.as_text()
			for i in global.config.bindings:
				if global.config.bindings[i].has("keys"):
					if global.config.bindings[i].keys.has(event_text):
						actions.append(i)
		if event is InputEventMouseButton:
			var event_button = str(event.button_index)
			for i in global.config.bindings:
				if global.config.bindings[i].has("buttons"):
					if global.config.bindings[i].buttons.has(event_button):
						actions.append(i)
		if event is InputEventJoypadButton:
			var event_button = Input.get_joy_button_string(event.button_index)
			for i in global.config.bindings:
				if global.config.bindings[i].has("joy_buttons"):
					if global.config.bindings[i].joy_buttons.has(event_button):
						actions.append(i)
	return actions

func check_action_pressed(action):
	var y = false
	if global.config.bindings.has(action):
		if global.config.bindings[action].has("keys"):
			for i in global.config.bindings[action].keys:
				if Input.is_key_pressed(OS.find_scancode_from_string(i)):
					y = true
		if global.config.bindings[action].has("buttons"):
			for i in global.config.bindings[action].buttons:
				if Input.is_mouse_button_pressed(int(i)):
					y = true
		if global.config.bindings[action].has("joy_buttons"):
			for d in Input.get_connected_joypads():
				for i in global.config.bindings[action].joy_buttons:
					if Input.is_joy_button_pressed(d, Input.get_joy_button_index_from_string(i)):
						y = true
	return y

func check_joy_axis():
	var tmp = 0
	for d in Input.get_connected_joypads():
		var tmp2 = Input.get_joy_axis(d, Input.get_joy_axis_index_from_string("Left Stick X"))
		if abs(tmp2) > abs(tmp):
			tmp = tmp2
	global.axis_states["Left Stick X"] = tmp
	tmp = 0
	for d in Input.get_connected_joypads():
		var tmp2 = Input.get_joy_axis(d, Input.get_joy_axis_index_from_string("Left Stick Y"))
		if abs(tmp2) > abs(tmp):
			tmp = tmp2
	global.axis_states["Left Stick Y"] = tmp
	tmp = 0
	for d in Input.get_connected_joypads():
		var tmp2 = Input.get_joy_axis(d, Input.get_joy_axis_index_from_string("Right Stick X"))
		if abs(tmp2) > abs(tmp):
			tmp = tmp2
	global.axis_states["Right Stick X"] = tmp
	tmp = 0
	for d in Input.get_connected_joypads():
		var tmp2 = Input.get_joy_axis(d, Input.get_joy_axis_index_from_string("Right Stick Y"))
		if abs(tmp2) > abs(tmp):
			tmp = tmp2
	global.axis_states["Right Stick Y"] = tmp

func check_action_axis(action):
	var r = 0
	if global.config.bindings.has(action):
		if global.config.bindings[action].has("axis"):
			for i in global.config.bindings[action].axis:
				if global.axis_states.has(i[0]):
					var value = global.axis_states[i[0]] * i[1]
					if value > 0.05:
						r = value
	return r

func check_cursor_action():
	if ! cursor_busy:
		cursor_busy = true
		var axis = false
		var force_l = global.check_action_axis("cursor_left")
		var force_r = global.check_action_axis("cursor_right")
		var force_u = global.check_action_axis("cursor_up")
		var force_d = global.check_action_axis("cursor_down")
		if force_l > 0 || force_r > 0 || force_u > 0 || force_d > 0:
			axis = true
		if axis:
			var window_size = get_viewport().get_size()
			var distance = min(sqrt(pow(force_r - force_l, 2) + pow(force_d - force_u, 2)), 1)
			distance = pow(distance, 5)
			var x = get_viewport().get_mouse_position().x + (force_r - force_l) * distance * global.config.cursor_speed
			var y = get_viewport().get_mouse_position().y + (force_d - force_u) * distance * global.config.cursor_speed
			x = clamp(x, 1, window_size.x - 1)
			y = clamp(y, 1, window_size.y - 1)
			get_viewport().warp_mouse(Vector2(x, y))
		cursor_busy = false

func check_input():
	var inputs = []
	for i in get_tree().get_nodes_in_group("interactables"):
		inputs.append(i.check_inside())
	var which = ["menu", -2]
	for i in inputs:
		if i[1] > which[1]:
			which = i
	if global.which_input != which:
		global.which_input = which

func calculate_volumes():
	global.volume["language"] = global.convert_volume(global.config.volume_language * global.config.volume_master)
	global.volume["music"] = global.convert_volume(global.config.volume_music * global.config.volume_master)
	global.volume["background"] = global.convert_volume(global.config.volume_background * global.config.volume_master)
	global.volume["video"] = global.convert_volume(global.config.volume_video * global.config.volume_master)

func convert_volume(factor):
	return 8.68588963807 * log(factor)