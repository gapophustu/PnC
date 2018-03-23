extends Control

const id = "Scene1"
const move_speed = 0.005
const move_margin = 0.05

var scale_new = 1
var move_direction_x = "none"
var move_direction_y = "none"
var scene_offset = Vector2(0, 0)
var max_offset = Vector2(0, 0)
var paused = false

var messages_load = preload("./Messages.tscn")
var messages = messages_load.instance()
var inventory_load = preload("./Inventory.tscn")
var inventory = inventory_load.instance()
var cursor_menu_load = preload("res://Menu/CursorMenu.tscn")
var cursor_menu

var star_load = preload("./Star/Object.tscn")
var star = star_load.instance()
var tree_load = preload("./Tree/StaticObject.tscn")
var tree = tree_load.instance()

var pos_player = Vector2(1000, 1000)

func _ready():
	make_navigation_polygon()
	add_to_group("pausables")
	add_to_group("interactables")
	add_to_group("resizes")
	add_to_group("inputable")
	set_physics_process(true)
	set_process(true)
	set_process_input(false)
	resize()
	
	$Background.add_child(star)
	$Background.add_child(tree)
	add_child(messages)
	add_child(inventory)

func pause(pause):
	paused = pause

func check_inside():
	return [id, 0]

func resize():
	scale_new = global.config.scale
	var window_size = OS.get_window_size()
	var texture_size = $Background.texture.get_size()
	var scale_x = window_size.x / texture_size.x
	var scale_y = window_size.y / texture_size.y
	var scale_xy = max(scale_x, scale_y)
	scale_new = max(scale_new, scale_xy)
	$Background.scale = Vector2(scale_new, scale_new)
	max_offset.x = texture_size.x * scale_new - window_size.x
	max_offset.y = texture_size.y * scale_new - window_size.y
	if global.config.camera_mode == "scroll":
		calculate_offset()
	elif global.config.camera_mode == "follow_cursor":
		center_scene($Background.get_local_mouse_position())

func _physics_process(delta):
	calculate_offset()

func calculate_offset():
	if global.config.camera_mode == "scroll":
		var axis = false
		var force_l = global.check_action_axis("scroll_left")
		var force_r = global.check_action_axis("scroll_right")
		var force_u = global.check_action_axis("scroll_up")
		var force_d = global.check_action_axis("scroll_down")
		if force_l > 0 || force_r > 0 || force_u > 0 || force_d > 0:
			axis = true
		var window_size = OS.get_window_size()
		var temp_scene_offset = scene_offset
		if force_l > 0:
			temp_scene_offset.x += window_size.x * move_speed * 2 * force_l
		else:
			temp_scene_offset.x -= window_size.x * move_speed * 2 * force_r
		if force_u > 0:
			temp_scene_offset.y += window_size.y * move_speed * 2 * force_u
		else:
			temp_scene_offset.y -= window_size.y * move_speed * 2 * force_d
		if ! axis && global.which_input[1] < 256:
			if move_direction_x == "left" || global.check_action_pressed("scroll_left"):
				temp_scene_offset.x += window_size.x * move_speed
			if move_direction_x == "right" || global.check_action_pressed("scroll_right"):
				temp_scene_offset.x -= window_size.x * move_speed
			if move_direction_y == "up" || global.check_action_pressed("scroll_up"):
				temp_scene_offset.y += window_size.y * move_speed
			if move_direction_y == "down" || global.check_action_pressed("scroll_down"):
				temp_scene_offset.y -= window_size.y * move_speed
		scene_offset.x = round(clamp(temp_scene_offset.x, -max_offset.x, 0))
		scene_offset.y = round(clamp(temp_scene_offset.y, -max_offset.y, 0))

func center_scene(pos):
	var texture_size = $Background.texture.get_size()
	scene_offset.x = round(clamp(-pos.x * max_offset.x / texture_size.x, -max_offset.x, 0))
	scene_offset.y = round(clamp(-pos.y * max_offset.y / texture_size.y, -max_offset.y, 0))

func input(actions):
	if global.which_input[0] == id:
		if actions.has("interact"):
			interact()
	if global.which_input[1] <= 255:
		if actions.has("cursor_moved"):
			var pos = get_viewport().get_mouse_position()
			if global.config.camera_mode == "scroll":
				var window_size = OS.get_window_size()
				if pos.x <= move_margin * window_size.x:
					move_direction_x = "left"
				elif pos.x >= window_size.x - move_margin * window_size.x:
					move_direction_x = "right"
				else:
					move_direction_x = "none"
				if pos.y <= move_margin * window_size.y:
					move_direction_y = "up"
				elif pos.y >= window_size.y - move_margin * window_size.y:
					move_direction_y = "down"
				else:
					move_direction_y = "none"
			elif global.config.camera_mode == "follow_cursor":
				center_scene($Background.get_local_mouse_position())
		if actions.has("highlight"):
			if global.config.highlight:
				global.highlighted = true
	if global.which_input[1] <= 300:
		if actions.has("toggle_inventory"):
			inventory.open = ! inventory.open
		if actions.has("open_inventory"):
			inventory.open = true
		if actions.has("close_inventory"):
			inventory.open = false

func _process(delta):
	draw_scene()

func draw_scene():
	$Background.position = scene_offset

func transfor_coordinates(pos):
	return pos * $Background.scale + scene_offset

func make_navigation_polygon():
	var config = ConfigFile.new()
	config.load("res://images/backgrounds/Background1.cfg")
	for i in config.get_section_keys("paths"):
		$Navigation2D/NavigationPolygonInstance.navpoly.add_outline(config.get_value("paths", i))
	$Navigation2D/NavigationPolygonInstance.navpoly.make_polygons_from_outlines()
	$Navigation2D/NavigationPolygonInstance.enabled = false
	$Navigation2D/NavigationPolygonInstance.enabled = true

func cursor_menu(parent_id):
	cursor_menu = cursor_menu_load.instance()
	add_child(cursor_menu)
	cursor_menu.parent_id = parent_id

func interact():
	var pos = $Background.get_local_mouse_position()
	var img = $Background/Height.texture.get_data()
	img.lock()
	var height = round(img.get_pixel(pos.x, pos.y)[0] * 255)
	if height > 0:
		var path = $Navigation2D.get_simple_path(pos_player, pos)
		pos_player = pos
		$Background/Node2D.path = path