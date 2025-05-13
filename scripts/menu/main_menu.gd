extends Control
class_name MainMenu

var is_button_pressed: bool = false

func _ready() -> void:
	for _button in get_tree().get_nodes_in_group("menu_button"):
		_button.pressed.connect(_on_button_pressed.bind(_button))


func _on_button_pressed(_button_pressed: Button) -> void:
	print(_button_pressed.name)
	if is_button_pressed:
		return

	is_button_pressed = true
	
	match _button_pressed.name:
		"NewGame":
			Global.current_scene_path = "res://scenes/levels/Caverna/caverna.tscn"
			transition_screen.fade_in()
		"Exit":
			get_tree().quit()
