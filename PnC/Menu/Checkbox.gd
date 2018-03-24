extends Control

signal changed

var id = "checkbox"

var z_index = -1
var text_id = ""
var size = Vector2(600, 60)
var disabled = false
var checked = false

func _ready():
	add_to_group("resizes")
	add_to_group("translations")
	add_to_group("inputable")
	add_to_group("interactables")
	set_process(true)
	$Label.add_font_override("font", $Label.get_font("font").duplicate())
	var color = Color(0, 0, 0)
	var style = StyleBoxFlat.new()
	$Background.add_stylebox_override("panel", style)
	style.set_bg_color(color)
	color = Color(0.2, 0.2, 0.2)
	style = StyleBoxFlat.new()
	$Foreground.add_stylebox_override("panel", style)
	style.set_bg_color(color)
	
	update()

func _process(delta):
	var color = Color(0.4, 0.4, 0.4)
	var style = StyleBoxFlat.new()
	$CheckboxBackground.add_stylebox_override("panel", style)
	if global.which_input[0] == id && ! disabled:
		color = Color(0.6, 0.6, 0.6)
	style.set_bg_color(color)
	if disabled:
		color = Color(0.4, 0.4, 0.4)
	else:
		color = Color(1, 1, 1)
	$Label.add_color_override("font_color", color)
	if checked:
		$Checkbox.modulate.a = 1
	else:
		$Checkbox.modulate.a = 0

func update():
	_on_switch_locale()

func _on_switch_locale():
	$Label.text = TranslationServer.translate(text_id)
	resize()

func resize():
	$Background.rect_size = size
	var margin = 1
	margin = max(margin, round($Background.rect_size.x * 0.005))
	margin = max(margin, round($Background.rect_size.y * 0.005))
	$Foreground.rect_size.x = $Background.rect_size.x - margin * 2
	$Foreground.rect_size.y = $Background.rect_size.y - margin * 2
	$Foreground.rect_position = Vector2(margin, margin)
	$CheckboxBackground.rect_size.x = $Foreground.rect_size.y - 4 * margin
	$CheckboxBackground.rect_size.y = $CheckboxBackground.rect_size.x
	$CheckboxBackground.rect_position.x = $Foreground.rect_position.x + $Foreground.rect_size.x - $CheckboxBackground.rect_size.x - 2 * margin
	$CheckboxBackground.rect_position.y = ($Background.rect_size.y - $CheckboxBackground.rect_size.y) / 2
	$Checkbox.rect_size.x = $CheckboxBackground.rect_size.x - 2 * margin
	$Checkbox.rect_size.y = $Checkbox.rect_size.x
	$Checkbox.rect_position = $CheckboxBackground.rect_position + Vector2(margin, margin)
	$Label.get_font("font").size = int($Foreground.rect_size.y * 0.75)
	var text_size = $Label.get_font("font").get_string_size($Label.text)
	if text_size.y > $Foreground.rect_size.y || text_size.x > $Foreground.rect_size.x - 2 * margin:
		$Label.get_font("font").size = int(min($Foreground.rect_size.y / text_size.y, ($Foreground.rect_size.x - 2 * margin) / text_size.x) * $Label.get_font("font").size)
	$Label.rect_size = Vector2(0, 0)
	$Label.rect_position.x = $Foreground.rect_position.x + margin
	$Label.rect_position.y = ($Background.rect_size.y - $Label.rect_size.y) / 2
	

func input(actions):
	if global.which_input[0] == id:
		if global.check_action_pressed("interact"):
			if ! disabled:
				checked = ! checked
				emit_signal("changed")

func check_inside():
	var index = -1
	var pos = Vector2(round($CheckboxBackground.get_local_mouse_position().x), round($CheckboxBackground.get_local_mouse_position().y))
	if pos.x >= 0 && pos.y >= 0 && pos.x < $CheckboxBackground.rect_size.x && pos.y < $CheckboxBackground.rect_size.y:
		index = z_index
	return [id, index]