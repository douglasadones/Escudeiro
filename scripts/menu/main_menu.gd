extends Control
class_name MainMenu

var is_button_pressed: bool = false
var buttons := []
var current_index := 0

func _ready() -> void:
	# Pega todos os botões do grupo "menu_button"
	buttons = get_tree().get_nodes_in_group("menu_button")

	# Conecta sinal pressed e define foco para cada botão
	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_button_pressed.bind(buttons[i]))
		buttons[i].focus_mode = Control.FOCUS_ALL
		# Define current_index para o botão NewGame
		if buttons[i].name == "NewGame":
			current_index = i

	# Dá foco no botão NewGame para começar
	if buttons.size() > 0:
		buttons[current_index].grab_focus()

	Music.set_music("res://assets/OST/Menu/Menu song.wav", "")
	Music.play()
	Pausa.disable_pause_menu()
	

func _process(delta: float) -> void:
	if is_button_pressed or buttons.size() == 0:
		return

	# Navegação para cima, só se não estiver no primeiro botão
	if Input.is_action_just_pressed("ui_up"):
		print(current_index)
		if current_index > 0:
			if current_index != 1:
				current_index -= 1
			buttons[current_index].grab_focus()

	# Navegação para baixo, só se não estiver no último botão
	elif Input.is_action_just_pressed("ui_down"):
		print(current_index)
		if current_index < buttons.size() - 1:
			current_index += 1
			buttons[current_index].grab_focus()

	# Ativa o botão atual com Enter/Espaço
	elif Input.is_action_just_pressed("ui_accept"):
		buttons[current_index].emit_signal("pressed")


func _on_button_pressed(_button_pressed: Button) -> void:
	print("Botão pressionado:", _button_pressed.name)
	if is_button_pressed:
		return
	is_button_pressed = true

	match _button_pressed.name:
		"NewGame":
			Global.current_scene_path = "res://scenes/cutscene/cut_scene.tscn"
			transition_screen.fade_in()
		"Exit":
			get_tree().quit()
