extends Node2D

const id = "inventory"
const margin_left = 55
const margin_bottom = 58
const margin_right = 72

var open = false
var new_scale = 1
var inside = false
var paused = false

func _ready():
	add_to_group("pausables")
	add_to_group("resizes")
	add_to_group("interactables")
	add_to_group("inputable")
	z_index = 300
	modulate.a = 0
	resize()
	position.y = round(-$Background.texture.get_size().x * new_scale)

func pause(pause):
	paused = pause

func return_state():
	var state = {}
	return state

func resize():
	var window_size = OS.get_window_size()
	new_scale = window_size / $Background.texture.get_size()
	new_scale = min(new_scale.x, new_scale.y)
	$Background.scale = Vector2(new_scale, new_scale)
	position.x = (window_size.x - $Background.texture.get_size().x * new_scale) / 2

func _physics_process(delta):
	if ! paused:
		place_inventory()

func place_inventory():
	if open && position.y < 0:
		var window_size = OS.get_window_size()
		position.y += window_size.y / 50
		position.y = min(position.y, 0)
		if position.y > -$Background.texture.get_size().y * new_scale && modulate.a < 1:
			modulate.a = 1
	elif ! open && position.y > -$Background.texture.get_size().y * new_scale:
		var window_size = OS.get_window_size()
		position.y -= window_size.y / 50
		position.y = max(position.y, round(-$Background.texture.get_size().y * new_scale))
		if position.y == round(-$Background.texture.get_size().y * new_scale) && modulate.a != 0:
			modulate.a = 0

func check_inside():
	var index = -1
	if modulate.a > 0:
		index = z_index
	return [id, index]

func input(actions):
	if global.which_input[0] == id:
		if actions.has("cursor_moved"):
			var pos = $Background.get_local_mouse_position()
			var size = $Background.texture.get_size()
			if pos.x < 0 + margin_left || pos.x > size.x - margin_right || pos.y > size.y - margin_bottom:
				if inside:
					open = false
				inside = false
			else:
				inside = true