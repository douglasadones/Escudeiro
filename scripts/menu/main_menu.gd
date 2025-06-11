extends Control
class_name MainMenu

var is_button_pressed: bool = false
var buttons := []
var current_index := 0

func _ready() -> void:
	# Pega todos os botões do grupo "menu_button"
	buttons = get_tree().get_nodes_in_group("menu_button")
	
	# Garante que os botões estejam na ordem correta (de cima para baixo)
	buttons.sort_custom(func(a, b): return a.position.y < b.position.y)

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
	
# -- FUNÇÃO _process CORRIGIDA --
func _process(delta: float) -> void:
	if is_button_pressed or buttons.size() == 0:
		return

	# Navegação para cima, só se não estiver no primeiro botão
	if Input.is_action_just_pressed("ui_up"):
		if current_index > 0:
			# ##-- CORREÇÃO: Lógica simplificada e correta --##
			current_index -= 1
			buttons[current_index].grab_focus()

	# Navegação para baixo, só se não estiver no último botão
	elif Input.is_action_just_pressed("ui_down"):
		if current_index < buttons.size() - 1:
			current_index += 1
			buttons[current_index].grab_focus()

	# Ativa o botão atual com Enter/Espaço
	elif Input.is_action_just_pressed("ui_accept"):
		# ##-- MELHORIA: Chama a função diretamente em vez de emitir o sinal --##
		_on_button_pressed(buttons[current_index])


func _on_button_pressed(_button_pressed: Button) -> void:
	if is_button_pressed:
		return
	is_button_pressed = true
	
	# Para o som do foco do botão, se houver
	# $FocusSound.play() 

	print("Botão pressionado:", _button_pressed.name)

	match _button_pressed.name:
		"NewGame":
			Global.current_scene_path = "res://scenes/cutscene/cut_scene.tscn"
			transition_screen.fade_in()
		"Exit":
			get_tree().quit()
