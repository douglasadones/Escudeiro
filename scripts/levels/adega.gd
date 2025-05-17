extends Node2D
class_name Adega

const DIALOG_SYSTEM: PackedScene = preload("res://scenes/ui/dialog_box.tscn")
@export var scene_path: String
var pode_interagir: bool = false
var dialog: int = 0

@onready var player = get_tree().get_current_scene().get_node("Escudeiro")
@onready var animated_sprite = player.get_node("Texture")

var dialogo_inicial: Dictionary = {
		0: {
		"title": "",
		"dialog": "Pule para subir",
	},
}

func _ready() -> void:
	Global.current_scene_path = scene_path

func _process(delta: float) -> void:
	if pode_interagir and Input.is_action_just_pressed("pular"):
		Global.current_scene_path = "res://scenes/levels/Caverna/caverna.tscn"
		transition_screen.fade_in()
		

func _on_area_2d_body_entered(body: Node2D) -> void:
	dialog += 1
	if body.name == "Escudeiro":
		pode_interagir = true
		if dialog > 2:
			animated_sprite.play("idle")
			spawn_dialog(dialogo_inicial)
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir = false

func spawn_dialog(dialog_info: Dictionary) -> void:
	var ds: DialogBox = DIALOG_SYSTEM.instantiate()
	ds.dialog_data = dialog_info
	add_child(ds)
