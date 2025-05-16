extends Control
class_name DialogSystem

var is_finished: bool = false
var dialog_index: int = 0
var dialog_data: Dictionary = {
	0: {
		"title": "Escudeiro",
		"dialog": "Hello world!",
	},
}

@onready var title: Label = $VBoxContainer/Title
@onready var dialog_text: Label = $VBoxContainer/Label
@onready var skip: Polygon2D = $Skip

func _ready() -> void:
	load_dialog()
	

func _process(delta: float) -> void:
	skip.visible = is_finished
	if Input.is_action_just_pressed("pular") and is_finished:
		dialog_index += 1
		if dialog_data.has(dialog_index):
			load_dialog()
			return
		queue_free()


func load_dialog() -> void:
	is_finished = false
	title.text = dialog_data[dialog_index]["title"]
	dialog_text.text = dialog_data[dialog_index]["dialog"]
	
	dialog_text.visible_ratio = 0
	while dialog_text.visible_ratio < 1:
		await get_tree().physics_frame
		dialog_text.visible_ratio += 0.01
	is_finished = true
