extends CanvasLayer
class_name DialogBox

signal dialog_finished

var is_finished: bool = false
var is_typing: bool = false
var automatico: bool = true
var dialog_index: int = 0

var dialog_data: Dictionary = {
	0: {
		"title": "Escudeiro",
		"dialog": "Hello world!",
	},
}

@onready var title: Label = $DialogSystem/VBoxContainer/Title
@onready var label: Label = $DialogSystem/VBoxContainer/Label
@onready var skip: Polygon2D = $DialogSystem/Skip
@onready var player = get_tree().get_current_scene().get_node("Escudeiro")
@onready var audio: AudioStreamPlayer2D = $DialogSystem/Audio

func _ready() -> void:
	load_dialog()

func _process(delta: float) -> void:
	skip.visible = is_finished

	if Input.is_action_just_pressed("pular"):
		if is_typing:
			label.visible_ratio = 1
			is_typing = false
			is_finished = true
		elif is_finished:
			dialog_index += 1
			if dialog_data.has(dialog_index):
				load_dialog()
			else:
				queue_free()
				if player:
					player.set_physics_process(true)
				emit_signal("dialog_finished")

func load_dialog() -> void:
	is_finished = false
	is_typing = true

	title.text = dialog_data[dialog_index]["title"]
	label.text = dialog_data[dialog_index]["dialog"]

	if player:
		player.set_physics_process(false)

	label.visible_ratio = 0
	var audio_delay := 0.1
	var time_passed := 0.0

	while label.visible_ratio < 1:
		if not is_typing:
			break  # se o jogador pulou a digitação
		await get_tree().physics_frame
		label.visible_ratio += 0.01
		time_passed += get_process_delta_time()
		if time_passed >= audio_delay:
			audio.play()
			time_passed = 0.0

	audio.stop()
	is_typing = false
	is_finished = true

func is_dialog_finished() -> bool:
	return dialog_index >= dialog_data.size()
