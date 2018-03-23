extends Node2D

var path = [Vector2(0,0), Vector2(50, 50)]

func _ready():
	set_process(true)
	z_index = 1000

func _process(delta):
	update()

func _draw():
	for i in path.size() - 1:
		 draw_line(path[i], path[i + 1], Color(255, 0, 0), 1)