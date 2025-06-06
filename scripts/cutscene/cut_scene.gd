extends Control
class_name CutScene

@onready var v_box_container: VBoxContainer = $VBoxContainer
var is_finished: bool = false
var dialog_index: int = 0
var is_typing: bool = false  # flag para controlar se está "digitando" o texto
var dialog_data: Dictionary = {
	0: {"title": "Bárbara:", "dialog": "Eu prometo!", "color": 1},
	1: {"title": "", "dialog": "...", "color": 0},
	2: {"title": "Escudeiro:", "dialog": "Senhora…", "color": 0},
	3: {"title": "Escudeiro:", "dialog": "Por favor, não faça isso.", "color": 0},
	4: {"title": "Escudeiro:", "dialog": "Mas se é esse o seu desejo…", "color": 0},
	5: {"title": "Escudeiro:", "dialog": "Meu dever de Escudeiro…", "color": 0},
	6: {"title": "Escudeiro:", "dialog": "Cof-cof… Cof-cof… Cof-cof", "color": 0},
}

@onready var title: Label = $VBoxContainer/Title
@onready var dialog_text: Label = $VBoxContainer/Label
@onready var skip: Polygon2D = $Skip
@onready var audio: AudioStreamPlayer2D = $Audio

func _ready() -> void:
	load_dialog()

func _process(delta: float) -> void:
	skip.visible = is_finished
	if Input.is_action_just_pressed("pular"):
		if is_typing:
			# Se estiver escrevendo, mostra tudo direto
			dialog_text.visible_ratio = 1
			is_typing = false
			is_finished = true
		elif is_finished:
			# Se terminou de mostrar texto, avança
			dialog_index += 1
			if dialog_data.has(dialog_index):
				load_dialog()
			else:
				# Quando acabar os diálogos, faz o que precisar
				Global.current_scene_path = "res://scenes/levels/AreaInicial/area_inicial.tscn"
				transition_screen.cap01()
				queue_free()

func load_dialog() -> void:
	is_finished = false
	is_typing = true
	title.text = dialog_data[dialog_index]["title"]
	dialog_text.text = dialog_data[dialog_index]["dialog"]
	
	var audio_delay := 0.1
	var time_passed := 0.0 
	
	if dialog_data[dialog_index]["color"] == 1:
		v_box_container.modulate = Color(1, 0.5, 0)
	else:
		v_box_container.modulate = Color(1, 1, 1)

	dialog_text.visible_ratio = 0
	while dialog_text.visible_ratio < 1:
		if not is_typing:
			break  # sai do loop se o usuário quiser pular a animação
		await get_tree().physics_frame
		dialog_text.visible_ratio += 0.01
		
		time_passed += get_process_delta_time()
		if time_passed >= audio_delay:
			audio.play()
			time_passed = 0.0
	audio.stop()
	is_typing = false
	is_finished = true
