extends Node

func get(image):
	image.lock()
	var paths = []
	var starter = [true, "", Vector2(0, 0)]
	var direction = ""
	print(OS.get_ticks_msec())
	while starter[0]:
		starter = find_start(image, paths, starter[2])
		if starter[0]:
			if starter[1] == "right":
				direction = "up"
			else:
				direction = "left"
			var new_path = generate_path(image, starter[2], direction)
			paths.append({orientation = starter[1], vertices = new_path})
			print(starter)
	print(OS.get_ticks_msec())
	var config = ConfigFile.new()
	for i in paths.size():
		config.set_value("paths", str(i), optimize_path(paths[i].vertices))
	config.save("user://paths.cfg")

func get_pixel_information(image, paths, x, y):
	var dimensions = image.get_size()
	var result = {orientations = [], u_l = false, u_r = false, d_l = false, d_r = false}
	if x - 1 >= 0 && y < dimensions.y:
		result.d_l = image.get_pixel(x - 1, y)[0] != 0
	if x - 1 >= 0 && y - 1 >= 0:
		result.u_l = image.get_pixel(x - 1, y - 1)[0] != 0
	if x < dimensions.x && y - 1 >= 0:
		result.u_r = image.get_pixel(x, y - 1)[0] != 0
	if x < dimensions.x && y < dimensions.y:
		result.d_r = image.get_pixel(x, y)[0] != 0
	for i in paths:
		if i.vertices.has(Vector2(x, y)):
			result.orientations.append(i.orientation)
	return result

func is_start(information):
	var yes = false
	var orientation = "right"
	if information.orientations == []:
		if ! information.u_l && ! information.u_r && ! information.d_l && information.d_r:
			yes = true
		if information.u_l && information.u_r && information.d_l && ! information.d_r:
			yes = true
			orientation = "left"
	return [yes, orientation]

func find_start(image, paths, start):
	var dimensions = image.get_size()
	for y in dimensions.y:
		for x in dimensions.x:
			if y > start.y || (y == start.y && x >= start.x):
				var here = is_start(get_pixel_information(image, paths, x, y))
				if here[0]:
					here.append(Vector2(x, y))
					return here
	return [false]

func generate_path(image, start_point, start_direction):
	var path = []
	var pos = start_point
	var direction = start_direction
	while ! path.has(pos):
		path.append(pos)
		direction = get_next_direction(image, pos, direction)
		if direction == "left":
			pos.x -= 1
		if direction == "right":
			pos.x += 1
		if direction == "up":
			pos.y -= 1
		if direction == "down":
			pos.y += 1
	return path

func get_next_direction(image, pos, direction):
	var new_direction = ""
	var information = get_pixel_information(image, [], pos.x, pos.y)
	if ((information.u_l && ! information.u_r) || (! information.u_l && information.u_r)) && direction != "down":
		new_direction = "up"
	if ((information.u_l && ! information.d_l) || (! information.u_l && information.d_l)) && direction != "right":
		new_direction = "left"
	if ((information.u_r && ! information.d_r) || (! information.u_r && information.d_r)) && direction != "left":
		new_direction = "right"
	if ((information.d_l && ! information.d_r) || (! information.d_l && information.d_r)) && direction != "up":
		new_direction = "down"
	return new_direction

func optimize_path(path):
	var new_path = [path[0]]
	var new_direction = Vector2(0, 0)
	var pos = path[0]
	var pos_next = path[1]
	var old_direction = pos - pos_next
	for i in path.size() - 1:
		pos = path[i + 1]
		if i + 2 == path.size():
			pos_next = path[0]
		else:
			pos_next = path[i + 2]
		new_direction = pos - pos_next
		if new_direction != old_direction:
			new_path.append(pos)
		old_direction = new_direction
	return new_path