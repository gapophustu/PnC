extends Control

signal changed

var id = "slider"

var z_index = -1
var text_id = ""
var text_trailing = ""
var size = Vector2(600, 60)
var disabled = false
var value_range = [0, 100]
var value = 0
var sliding = false

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

func _process(delta):
	var color = Color(0.4, 0.4, 0.4)
	var style = StyleBoxFlat.new()
	$Slider.add_stylebox_override("panel", style)
	if (global.which_input[0] == id  || sliding) && ! disabled:
		color = Color(0.6, 0.6, 0.6)
	style.set_bg_color(color)
	if disabled:
		color = Color(0.4, 0.4, 0.4)
	else:
		color = Color(1, 1, 1)
	$Label.add_color_override("font_color", color)

func update():
	value = clamp(value, value_range[0], value_range[1])
	_on_switch_locale()

func _on_switch_locale():
	$Label.text = TranslationServer.translate(text_id) + ": " + str(value) + text_trailing
	resize()

func resize():
	$Background.rect_size = size
	var margin = 1
	margin = max(margin, round($Background.rect_size.x * 0.005))
	margin = max(margin, round($Background.rect_size.y * 0.005))
	$Foreground.rect_size.x = $Background.rect_size.x - margin * 2
	$Foreground.rect_size.y = $Background.rect_size.y - margin * 2
	$Foreground.rect_position = Vector2(margin, margin)
	var text = TranslationServer.translate(text_id) + ": " + str(value_range[1]) + text_trailing
	$Label.get_font("font").size = int($Foreground.rect_size.y * 0.75)
	var text_size = $Label.get_font("font").get_string_size($Label.text)
	if text_size.y > $Foreground.rect_size.y || text_size.x > $Foreground.rect_size.x / 2 - 4 * margin:
		$Label.get_font("font").size = int(min($Foreground.rect_size.y / text_size.y, ($Foreground.rect_size.x / 2 - 4 * margin) / text_size.x) * $Label.get_font("font").size)
	$Label.rect_size = Vector2(0, 0)
	$Label.rect_position.x = $Foreground.rect_position.x + margin
	$Label.rect_position.y = ($Background.rect_size.y - $Label.rect_size.y) / 2
	$SliderBackground.rect_size.x = round($Foreground.rect_size.x / 2 - margin)
	$SliderBackground.rect_size.y = $Foreground.rect_size.y / 10
	$SliderBackground.rect_position.x = $Foreground.rect_position.x + $Foreground.rect_size.x - $SliderBackground.rect_size.x - 2 * margin
	$SliderBackground.rect_position.y = ($Background.rect_size.y - $SliderBackground.rect_size.y) / 2
	$Slider.rect_size.x = round(margin / 2) * 2
	$Slider.rect_size.y = $Foreground.rect_size.y * 0.5
	position_slider()

func position_slider():
	var slider_margin = $Slider.rect_size.x / 2
	var range_pos = (float(value) - value_range[0]) / (value_range[1] - value_range[0])
	var range_slider = $SliderBackground.rect_size.x + slider_margin
	$Slider.rect_position.x = $SliderBackground.rect_position.x - slider_margin + range_pos * range_slider
	$Slider.rect_position.y = ($Background.rect_size.y - $Slider.rect_size.y) / 2
	

func input(actions):
	if global.which_input[0] == id || sliding:
		if global.check_action_pressed("interact"):
			if ! disabled:
				sliding = true
				value = round($SliderBackground.get_local_mouse_position().x / $SliderBackground.rect_size.x * (value_range[1] - value_range[0]) + value_range[0])
				value = clamp(value, value_range[0], value_range[1])
				$Label.text = TranslationServer.translate(text_id) + ": " + str(value) + text_trailing
				position_slider()
				emit_signal("changed")
		else:
			sliding = false

func check_inside():
	var index = -1
	var size = $Background.rect_size
	var pos = Vector2(round($Slider.get_local_mouse_position().x), round($Slider.get_local_mouse_position().y))
	if pos.x >= 0 && pos.y >= 0 && pos.x < $Slider.rect_size.x && pos.y < $Slider.rect_size.y:
		index = z_index
	pos = Vector2(round($SliderBackground.get_local_mouse_position().x), round($SliderBackground.get_local_mouse_position().y))
	if pos.x >= 0 && pos.y >= 0 && pos.x < $SliderBackground.rect_size.x && pos.y < $SliderBackground.rect_size.y:
		index = z_index
	return [id, index]