extends Node2D
class_name Caverna

const DIALOG_SYSTEM: PackedScene = preload("res://scenes/ui/dialog_box.tscn")
@onready var place_holder: Area2D = $PlaceHolder

@onready var musica: AudioStreamPlayer2D = $Musica
@onready var musica_pausado: AudioStreamPlayer2D = $MusicaPausado



@export_category("Variables")
@export var scene_path: String

var pode_interagir: bool = false

var dialogo_inicial: Dictionary = {
		0: {
		"title": "",
		"dialog": "Um brilho discreto chamou sua atenção sobre a mesa... é um item!",
	},
}

func _ready() -> void:
	Global.current_scene_path = scene_path

func _process(delta: float) -> void:
	if pode_interagir and Input.is_action_just_pressed("interagir"):
		print("Clicou")
		spawn_dialog(dialogo_inicial)
		place_holder.queue_free()
		


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		Global.current_scene_path = "res://scenes/levels/Adega/adega.tscn"
		transition_screen.fade_in()


func _on_place_holder_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir = true
		

func _on_place_holder_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir = false
		
func spawn_dialog(dialog_info: Dictionary) -> void:
	var ds: DialogBox = DIALOG_SYSTEM.instantiate()
	ds.dialog_data = dialog_info
	add_child(ds)
	
func _on_troca_cena_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		Global.current_scene_path = "res://scenes/levels/Floresta/floresta.tscn"
		transition_screen.fade_in()
		

func _on_musica_finished() -> void:
	musica.play()

func _on_musica_pausado_finished() -> void:
	musica_pausado.play()
