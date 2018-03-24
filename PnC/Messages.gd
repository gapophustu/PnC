extends Node2D

const id = "messages"

var messages = []
var paused = false
var pause_time = 0

func _ready():
	add_to_group("interactables")
	add_to_group("inputable")
	add_to_group("pausables")
	z_index = 310
	set_physics_process(true)

func pause(pause):
	if ! paused && pause:
		pause_time = OS.get_ticks_msec()
		for i in messages:
			var audio_node = i[2].get_node("Audio")
			audio_node.stop()
	if paused && ! pause:
		if messages.size() > 0:
			var delta = OS.get_ticks_msec() - pause_time
			for i in messages:
				i[0] += delta
				i[1] += delta
	paused = pause

func check_inside():
	var index = -1
	if messages.size() > 0:
		for i in messages:
			var current_time = OS.get_ticks_msec()
			var start_time = i[0]
			var end_time = i[1]
			if start_time <= current_time && current_time < end_time:
				index = z_index
	return [id, index]

func input(actions):
	if global.which_input[0] == id:
		if actions.has("interact"):
			next_message()
		if actions.has("watch"):
			end_message()

func end_message():
	for i in messages:
		i[1] = -global.config.skip_delay

func next_message():
	var current_time = OS.get_ticks_msec()
	var delta = 0
	var skip = true
	for i in messages:
		var start_time = i[0]
		var end_time = i[1]
		if start_time + global.config.skip_delay <= current_time && current_time < end_time:
			delta = max(delta, end_time - current_time)
			i[0] = -global.config.skip_delay
			i[1] = -global.config.skip_delay
		elif start_time <= current_time && current_time < start_time + global.config.skip_delay:
			skip = false
	if skip:
		for i in messages:
			i[0] -= delta
			i[1] -= delta

func recive_message_id(id):
	if id == "star message":
		var stream_star_1 = load("res://Scene1/audio/WATCHSTAR_1_" + global.config.lang_sound + ".ogg")
		var stream_star_2 = load("res://Scene1/audio/WATCHSTAR_2_" + global.config.lang_sound + ".ogg")
		var current_time = OS.get_ticks_msec()
		var end_1 = current_time + stream_star_1.get_length() * 1000
		messages.append([current_time, end_1, $StarMessage, "WATCHSTAR_1", Vector2(1325, 900), stream_star_1])
		messages.append([end_1, end_1 + stream_star_2.get_length() * 1000, $StarMessage, "WATCHSTAR_2", Vector2(1325, 900), stream_star_2])

func _physics_process(delta):
	if ! paused:
		if messages.size() > 0:
			var window_size = OS.get_window_size()
			for i in messages:
				var start_time = i[0]
				var end_time = i[1]
				var node = i[2]
				var message = i[3]
				var pos = i[4]
				var sound = i[5]
				var audio_node = node.get_node("Audio")
				var current_time = OS.get_ticks_msec()
				if start_time <= current_time:
					if ! audio_node.playing:
						audio_node.stream = sound
						audio_node.stream.loop = false
						audio_node.volume_db = global.volume.language
						audio_node.play((current_time - float(start_time)) / 1000)
					if global.config.subtitles:
						node.get_font("font").size = global.config.text_size
						node.text = message
						node.rect_size = Vector2(0, 0)
						if node.rect_size.x > window_size.x:
							node.get_font("font").size = int(node.get_font("font").size * window_size.x / node.rect_size.x)
							node.rect_size = Vector2(0, 0)
						if node.rect_size.y > window_size.y:
							node.get_font("font").size = int(node.get_font("font").size * window_size.y / node.rect_size.y)
							node.rect_size = Vector2(0, 0)
						node.rect_position = global.scene.transfor_coordinates(pos)
						node.rect_position.x -= node.rect_size.x / 2
						node.rect_position.y -= node.rect_size.y
						node.rect_position.x = clamp(node.rect_position.x, 0, window_size.x - node.rect_size.x)
						node.rect_position.y = clamp(node.rect_position.y, 0, window_size.y - node.rect_size.y)
						node.visible = true
				if current_time > end_time:
					node.visible = false
					audio_node.stop()
					messages.erase(i)