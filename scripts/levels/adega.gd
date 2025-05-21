extends Node2D
class_name Adega

# Cena do sistema de diálogo
const DIALOG_SYSTEM: PackedScene = preload("res://scenes/ui/dialog_box.tscn")
const DIE_SCREEN: PackedScene = preload("res://scenes/transicao/die_screen.tscn")

# Referências a nós da cena
@onready var audio_effect: AudioStreamPlayer2D = $AudioEffect
@onready var player: Node2D = get_tree().get_current_scene().get_node("Escudeiro")
@onready var animated_sprite: AnimatedSprite2D = player.get_node("Texture")

# Caminho exportado da cena atual
@export var scene_path: String

# Flags de controle
var pode_interagir: bool = false
var pode_interagir_com_homem: bool = false
var dialogo_homem_mostrado: bool = false
var dialog: int = 0
var dialog_index: int = 0

# Controle de áudio ambiente
var tempo_espera: float = 5.0
var tempo_passado: float = 0.0

# Sons de choro
const CHORO: Array[AudioStream] = [
	preload("res://assets/audio/Sound Effects/Primeira Fase/Gemido de dor (enquanto dorme)/murmurio_soluco.wav"),
	preload("res://assets/audio/Sound Effects/Primeira Fase/Gemido de dor (enquanto dorme)/murmurio_suave.wav"),
	preload("res://assets/audio/Sound Effects/Primeira Fase/Gemido de dor (enquanto dorme)/respiracao.wav")
]

# Diálogos
var dialogo_inicial: Dictionary = {
	0: {"title": "Dica", "dialog": "Pule para subir"}
}

var dialogo_homem: Dictionary = {
	0: {"title": "Homem da mesa que dorme", "dialog": "Perdoa-me, minha pequena flor do campo."},
	1: {"title": "Homem da mesa que dorme", "dialog": "Malditos, monstros todos… aos infernos! Que morram por toda a eternidade em chamas! Não… sufocados! Minha filha, malditos…"},
	2: {"title": "Homem da mesa que dorme", "dialog": "Perdoa-me, filha… sou um covarde!"},
	3: {"title": "Escolha", "dialog": "Pegar a faca?"}
}

func _ready() -> void:
	Global.current_scene_path = scene_path

func _process(delta: float) -> void:
	# Interação com escada
	if pode_interagir and Input.is_action_just_pressed("pular"):
		Global.current_scene_path = "res://scenes/levels/Caverna/caverna.tscn"
		transition_screen.fade_in()

	# Interação com homem
	if pode_interagir_com_homem and Input.is_action_just_pressed("interagir"):
		if not dialogo_homem_mostrado:
			match dialog_index:
				0:
					spawn_dialog(dialogo_homem, false)
					dialog_index += 1
				1:
					spawn_dialog(dialogo_homem, false)
					dialog_index += 1
				2:
					spawn_dialog(dialogo_homem, false)
					dialog_index += 1
				3:
					spawn_dialog(dialogo_homem, false)
					dialogo_homem_mostrado = true
					dialog_index += 1
		else:
			dialog_index += 1
					
	if dialogo_homem_mostrado and Input.is_action_just_pressed("interagir") and dialog_index == 6:
		die()

	# Som ambiente de fundo (choro)
	if not audio_effect.playing:
		tempo_passado += delta
		if tempo_passado >= tempo_espera:
			audio_effect.stream = CHORO[randi() % CHORO.size()]
			audio_effect.pitch_scale = 1.0
			audio_effect.play()
			tempo_passado = 0.0
	else:
		tempo_passado = 0.0

# Detecção de entrada na área da escada
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir = true
		dialog += 1
		if dialog > 1:
			animated_sprite.play("idle")
			spawn_dialog(dialogo_inicial)

# Detecção de saída da área da escada
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir = false

# Detecção de entrada na área do homem
func _on_homem_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_com_homem = true

# Detecção de saída da área do homem
func _on_homem_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_com_homem = false

# Instancia e exibe a caixa de diálogo
func spawn_dialog(dialog_info: Dictionary, auto: bool = true) -> void:
	var ds := DIALOG_SYSTEM.instantiate()
	ds.dialog_data = dialog_info
	if not auto:
		ds.automatico = false
		ds.dialog_index = dialog_index
	add_child(ds)
	print(ds.dialog_index)
	ds.connect("dialog_finished", Callable(self, "_on_dialog_finished"))

func die() -> void:
	var ds = DIE_SCREEN.instantiate()
	add_child(ds)
	await get_tree().create_timer(8.0).timeout
	get_tree().reload_current_scene()
