extends Control

func _on_Global_tree_entered():
	global.base = get_tree().get_root()
	global._on_startup()