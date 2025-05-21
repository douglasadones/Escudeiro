extends Node2D
class_name Caverna

const DIALOG_SYSTEM: PackedScene = preload("res://scenes/ui/dialog_box.tscn")

@onready var place_holder: Area2D = $PlaceHolder

@export_category("Variables")
@export var scene_path: String

var pode_interagir: bool = false

var dialogo_inicial: Dictionary = {
	0: {
		"title": "Garrafa de Vinho Forte​",
		"dialog": "Vinho adulterado, mais alcoólico do que deveria. Use-o para evitar
ser tomado pelo terror.",
	},
}

func _ready() -> void:
	Global.current_scene_path = scene_path
	var escudeiro = get_node("Escudeiro")
	if Global.primeira_vez_caverna:
		escudeiro.position = Vector2(100, 160)
		Global.primeira_vez_caverna = false
	escudeiro.position = Global.spawn_pos_escudeiro
	if Global.foi_pra_floresta:
		Music.set_music("res://assets/OST/Cave/Cave theme loop.wav", "res://assets/OST/Cave/cave theme pause loop.wav")
		Global.foi_pra_floresta = false
	if !Music.tocando:
		Music.play()
	Pausa.enable_pause_menu()

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
