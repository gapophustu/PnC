extends Control

func _ready():
	scan_height.get($Sprite.texture.get_data())
