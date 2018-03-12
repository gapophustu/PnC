extends Node2D

const id = "star"

var count = 0
var interactable = true
var watchable = true
var paused = false

func _ready():
	add_to_group("pausables")
	add_to_group("interactables")
	add_to_group("game_state")
	add_to_group("inputable")
	set_physics_process(true)
	set_process(true)
	set_process_input(false)
	if global.game_state.has("star"):
		if global.game_state.star.has("count"):
			count = global.game_state.star.count
	position = Vector2(1300, 900)
	z_index = 97
	$Sprite/Highlight.modulate.a = 0

func pause(pause):
	paused = pause

func return_state():
	var state = {
		count=count
	}
	return state

func _physics_process(delta):
	highlight_object()

func highlight_object():
	$Sprite/Highlight.modulate.a = global.highlight_progrss * 0.8

func check_inside():
	var index = -1
	var img = $Sprite/Highlight.texture.get_data()
	img.lock()
	var pos = Vector2(round(get_local_mouse_position().x), round(get_local_mouse_position().y))
	if pos.x >= 0 && pos.y >= 0 && pos.x < img.get_width() && pos.y < img.get_height() && img.get_pixel(pos.x, pos.y)[3] > 0.2:
		index = z_index
	return [id, index]

func input(actions):
	if global.which_input[0] == id:
		if global.config.input_type == "default":
			if actions.has("interact"):
				interact()
			if actions.has("watch"):
				watch()
		elif global.config.input_type == "one_click":
			if actions.has("interact"):
				global.scene.cursor_menu(id)

func interact():
	print("interacted")
	count += 1
	global.update_game_state()

func watch():
	print("watched")
	global.scene.messages.recive_message_id("star message")