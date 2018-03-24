extends Node2D

const id ="load_menu"
const button_file = "./Button.tscn"

var button_load = preload(button_file)

var older = button_load.instance()
var newer = button_load.instance()
var load_name = button_load.instance()
var load_button = button_load.instance()
var delete = button_load.instance()
var back = button_load.instance()
var savegames = []
var savegame_buttons = []
var selected = ""
var scroll_pos = 0

func _ready():
	add_to_group("resizes")
	add_to_group("inputable")
	add_to_group("interactables")
	var color = Color(0, 0, 0, 0.8)
	var style = StyleBoxFlat.new()
	z_index = 500
	$Background.add_stylebox_override("panel", style)
	style.set_bg_color(color)
	older.id = "older"
	older.text_id = "MENU_OLDER"
	older.z_index = z_index + 1
	older.connect("clicked", self, "_on_older_pressed")
	add_child(older)
	newer.id = "newer"
	newer.text_id = "MENU_NEWER"
	newer.z_index = z_index + 1
	newer.connect("clicked", self, "_on_newer_pressed")
	add_child(newer)
	load_name.id = "load_name"
	load_name.z_index = z_index + 1
	load_name.disabled = true
	add_child(load_name)
	back.id = "Back"
	back.text_id = "MENU_BACK"
	back.z_index = z_index + 1
	back.connect("clicked", self, "_on_back_pressed")
	add_child(back)
	load_button.id = "load_button"
	load_button.text_id = "MENU_LOAD_GAME"
	load_button.z_index = z_index + 1
	load_button.connect("clicked", self, "load_game")
	add_child(load_button)
	delete.id = "delete"
	delete.text_id = "MENU_DELETE_SAVE"
	delete.z_index = z_index + 1
	delete.connect("clicked", self, "delete_save")
	add_child(delete)
	read_save_dir()
	create_buttons()
	resize()

func _physics_process(delta):
	older.disabled = scroll_pos == 0
	newer.disabled = scroll_pos >= savegames.size() - 5

func _on_older_pressed():
	scroll_pos = max(0, scroll_pos - 1)
	resize()

func _on_newer_pressed():
	scroll_pos += 1
	if scroll_pos > savegames.size() - 5:
		scroll_pos -= 1
	resize()

func create_buttons():
	for i in savegames:
		var text = translate_date(i)
		savegame_buttons.append(button_load.instance())
		savegame_buttons[-1].id = i
		savegame_buttons[-1].text_trailing = text
		savegame_buttons[-1].z_index = z_index + 1
		savegame_buttons[-1].connect("selected", self, "_on_selected_pressed")
		add_child(savegame_buttons[-1])
		_on_selected_pressed(i)

func _on_selected_pressed(id):
	selected = id
	load_name.text_trailing = translate_date(selected)
	load_name.update()

func translate_date(date):
	var time = date
	time.erase(0, 11)
	time = time.replace("-", ":")
	date.erase(10, 9)
	return date + " " + time

func input(actions):
	if global.which_input[0] == id || global.which_input[1] == z_index + 1:
		if actions.has("watch"):
			_on_back_pressed()

func resize():
	var window_size = OS.get_window_size()
	$Background.rect_size = window_size
	var item_width = window_size.x * 0.8
	var item_height = window_size.y * 0.8 / 8
	var item_pos_x = window_size.x * 0.1
	older.size.x = item_width / 2
	older.size.y = item_height
	older.rect_position.x = item_pos_x
	older.rect_position.y = window_size.y * 0.1
	older.update()
	newer.size.x = item_width / 2
	newer.size.y = item_height
	newer.rect_position.x = item_pos_x
	newer.rect_position.y = window_size.y * 0.1 + item_height * 6
	newer.update()
	load_name.size.x = item_width / 2
	load_name.size.y = item_height
	load_name.rect_position.x = item_pos_x + item_width / 2
	load_name.rect_position.y = window_size.y * 0.1
	load_name.update()
	for i in savegame_buttons.size():
		savegame_buttons[i].size.x = item_width / 2
		savegame_buttons[i].size.y = item_height
		savegame_buttons[i].rect_position.x = item_pos_x
		if i >= scroll_pos && i < scroll_pos + 5:
			savegame_buttons[i].rect_position.y = window_size.y * 0.1 + item_height * (i + 1 - scroll_pos)
		else:
			savegame_buttons[i].rect_position.y = window_size.y
		savegame_buttons[i].update()
	load_button.size.x = item_width / 2
	load_button.size.y = item_height
	load_button.rect_position.x = item_pos_x + item_width / 2
	load_button.rect_position.y = window_size.y * 0.1 + item_height * 1
	load_button.update()
	delete.size.x = item_width / 2
	delete.size.y = item_height
	delete.rect_position.x = item_pos_x + item_width / 2
	delete.rect_position.y = window_size.y * 0.1 + item_height * 4
	delete.update()
	back.size.x = item_width
	back.size.y = item_height
	back.rect_position.x = item_pos_x
	back.rect_position.y = window_size.y * 0.1 + item_height * 7
	back.update()

func _on_back_pressed():
	queue_free()

func check_inside():
	var index = -1
	if get_parent().open:
		index = z_index
	return [id, index]

func read_save_dir():
	savegames = []
	var dir = Directory.new()
	dir.open("user://" + global.save_dir + "/")
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			savegames.append(file)
	dir.list_dir_end()
	savegames.sort()
	scroll_pos = max(0, savegames.size() - 5)

func delete_save():
	var savegame = Directory.new()
	if savegames.has(selected):
		savegame.remove("user://" + global.save_dir + "/" + selected)
	for i in savegame_buttons:
		i.queue_free()
	savegame_buttons = []
	read_save_dir()
	create_buttons()
	resize()

func load_game():
	if savegames.has(selected):
		global.load_game_state("user://" + global.save_dir + "/" + selected)
		global.menu.open = false
		queue_free()