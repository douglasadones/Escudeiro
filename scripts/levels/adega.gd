extends Node2D
class_name Adega

const DIALOG_SYSTEM: PackedScene = preload("res://scenes/ui/dialog_box.tscn")
@export var scene_path: String

var pode_interagir: bool = false
var dialog: int = 0

var tempo_espera = 5.0 
var tempo_passado = 0.0

@onready var player = get_tree().get_current_scene().get_node("Escudeiro")
@onready var animated_sprite = player.get_node("Texture")

@onready var audio_effect: AudioStreamPlayer2D = $AudioEffect

const CHORO: Array = [
	preload("res://assets/audio/Sound Effects/Primeira Fase/Gemido de dor (enquanto dorme)/murmurio_soluco.wav"),
	preload("res://assets/audio/Sound Effects/Primeira Fase/Gemido de dor (enquanto dorme)/murmurio_suave.wav"),
	preload("res://assets/audio/Sound Effects/Primeira Fase/Gemido de dor (enquanto dorme)/respiracao.wav")
]


var dialogo_inicial: Dictionary = {
		0: {
		"title": "",
		"dialog": "Pule para subir",
	},
}

func _ready() -> void:
	Global.current_scene_path = scene_path

func _process(delta):
	if pode_interagir and Input.is_action_just_pressed("pular"):
		Global.current_scene_path = "res://scenes/levels/Caverna/caverna.tscn"
		transition_screen.fade_in()

	if audio_effect.playing:
		# Reseta o timer enquanto o áudio está tocando
		tempo_passado = 0.0
	else:
		# Contabiliza o tempo parado
		tempo_passado += delta

		if tempo_passado >= tempo_espera:
			var index = randi() % CHORO.size()
			audio_effect.stream = CHORO[index]
			audio_effect.pitch_scale = 1.0
			audio_effect.play()
			tempo_passado = 0.0

	

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
