extends Node2D

const id = "cursor_menu"

var interactable = true
var watchable = true
var parent_id = ""

func _ready():
	add_to_group("interactables")
	add_to_group("inputable")
	z_index = 305
	var window_size = OS.get_window_size()
	position = get_viewport().get_mouse_position()
	position.x = clamp(position.x, 0 - $Interact.position.x, window_size.x - $Watch.position.x - $Watch.texture.get_size().x)
	position.y = clamp(position.y, 0 - $Interact.position.y, window_size.y - $Watch.position.y - $Watch.texture.get_size().y)

func check_inside():
	return [id, z_index]

func input(actions):
	if global.which_input[0] == id:
		if actions.has("interact"):
			var local_pos = $Interact.get_local_mouse_position()
			var size = $Interact.texture.get_size() * $Interact.scale
			var img = $Interact.texture.get_data()
			img.lock()
			var objects = get_tree().get_nodes_in_group("interactables")
			for i in objects:
				if i.id == parent_id:
					objects = i
			if local_pos.x >= 0 && local_pos.y >= 0 && local_pos.x < size.x && local_pos.y < size.y && img.get_pixel(local_pos.x, local_pos.y)[3] > 0.2 && interactable:
				objects.interact()
			else:
				local_pos = $Watch.get_local_mouse_position()
				size = $Watch.texture.get_size() * $Watch.scale
				img = $Watch.texture.get_data()
				img.lock()
				if local_pos.x >= 0 && local_pos.y >= 0 && local_pos.x < size.x && local_pos.y < size.y && img.get_pixel(local_pos.x, local_pos.y)[3] > 0.2 && watchable:
					objects.watch()
			queue_free()
	if global.which_input[1] > z_index:
		queue_free()