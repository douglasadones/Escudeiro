extends Node2D
class_name Caverna

@export_category("Variables")
@export var scene_path: String

func _ready() -> void:
	Global.current_scene_path = scene_path


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		Global.current_scene_path = "res://scenes/levels/Adega/adega.tscn"
		transition_screen.fade_in()
