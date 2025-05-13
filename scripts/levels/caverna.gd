extends Node2D
class_name Caverna

@export_category("Variables")
@export var scene_path: String

func _ready() -> void:
	Global.current_scene_path = scene_path
