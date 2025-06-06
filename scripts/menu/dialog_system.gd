extends Control
class_name DialogSystem

var is_finished: bool = false
var dialog_index: int = 0
var is_typing: bool = false  # flag para controlar se está "digitando" o texto
var dialog_data: Dictionary = {
	0: {
		"title": "Escudeiro:",
		"dialog": "",
	},
}

@onready var title: Label = $VBoxContainer/Title
@onready var dialog_text: Label = $VBoxContainer/Label
@onready var skip: Polygon2D = $Skip

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
			dialog_index += 1
			if dialog_data.has(dialog_index):
				load_dialog()
			else:
				queue_free()


func load_dialog() -> void:
	is_finished = false
	is_typing = true
	
	title.text = dialog_data[dialog_index]["title"]
	dialog_text.text = dialog_data[dialog_index]["dialog"]

	dialog_text.visible_ratio = 0
	while dialog_text.visible_ratio < 1:
		if not is_typing:
			break  # sai do loop se o usuário quiser pular a animação
		await get_tree().physics_frame
		dialog_text.visible_ratio += 0.01
	is_typing = false
	is_finished = true
	
