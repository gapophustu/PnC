extends Node2D

var path = []
var speed = 4

func _ready():
	z_index = 255
	set_process(true)
	set_physics_process(true)

func _process(delta):
	rescale()

func rescale():
	var height = global.scene.get_height(position)
	z_index = height
	if height == 0:
		print(position)
	var new_scale = 1 - (255 - height) / 500
	scale = Vector2(new_scale, new_scale)

func set_path(rough_path):
	if rough_path.size() > 0:
		rough_path = Array(rough_path)
		path = [rough_path[0]]
		var temp_pos = rough_path[0]
		rough_path.pop_front()
		var distance = 0
		while rough_path.size() > 0:
			while distance < speed && rough_path.size() > 0:
				var next_distance = temp_pos.distance_to(rough_path[0])
				if distance + next_distance > speed:
					temp_pos += (rough_path[0] - temp_pos) * (speed - distance) / next_distance
					distance = speed
				else:
					temp_pos = rough_path[0]
					rough_path.pop_front()
			distance = 0
			path.append(temp_pos)

func _physics_process(delta):
	if path.size() > 0:
		position = path[0]
		path.pop_front()
		if global.config.camera_mode == "follow_character":
			global.scene.center_scene(position)