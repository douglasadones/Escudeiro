extends Node2D
class_name Adega

# Cenas (inalterado)
const DIALOG_SYSTEM: PackedScene = preload("res://scenes/ui/dialog_box.tscn")
const DIE_SCREEN: PackedScene = preload("res://scenes/transicao/die_screen.tscn")
const CHOICE_BOX_SCENE: PackedScene = preload("res://scenes/ui/choise.tscn")

# Referências (inalterado)
@onready var audio_effect: AudioStreamPlayer2D = $AudioEffect
@onready var player: Node2D = get_tree().get_current_scene().get_node("Escudeiro")
@onready var animated_sprite: AnimatedSprite2D = player.get_node("Texture")

# --- MUDANÇA: Nova variável para controlar a sequência ---
@export var scene_path: String
var pode_interagir_escada: bool = false
var pode_interagir_com_homem: bool = false
var is_ambient_dialog_active: bool = false
# Este novo índice vai controlar a ordem dos diálogos de ambiente (0, 1, 2, 0, ...)
var ambient_dialog_index: int = 0

# Sons e Diálogos (inalterado)
const CHORO: Array[AudioStream] = [
	preload("res://assets/audio/Sound Effects/Primeira Fase/Gemido de dor (enquanto dorme)/murmurio_soluco.wav"),
	preload("res://assets/audio/Sound Effects/Primeira Fase/Gemido de dor (enquanto dorme)/murmurio_suave.wav"),
	preload("res://assets/audio/Sound Effects/Primeira Fase/Gemido de dor (enquanto dorme)/respiracao.wav")
]
const DIALOGOS_ALEATORIOS_HOMEM: Array[Dictionary] = [
	{"title": "Homem da mesa que dorme", "dialog": "Perdoa-me, minha pequena flor do campo."},
	{"title": "Homem da mesa que dorme", "dialog": "Malditos, monstros todos… aos infernos! ..."},
	{"title": "Homem da mesa que dorme", "dialog": "Perdoa-me, filha… sou um covarde!"},
]

func _ready() -> void:
	randomize()
	Global.current_scene_path = scene_path
	if !Music.tocando:
		Music.play()
	
	audio_effect.finished.connect(_on_audio_effect_finished)
	
	await get_tree().create_timer(5.0).timeout
	trigger_ambient_event()

func _process(delta: float) -> void:
	if pode_interagir_escada and Input.is_action_just_pressed("interagir"):
		Global.spawn_pos_escudeiro = Vector2(2200, 160)
		Global.current_scene_path = "res://scenes/levels/Caverna/caverna.tscn"
		transition_screen.fade_in()

	if pode_interagir_com_homem and Input.is_action_just_pressed("interagir"):
		audio_effect.stop()
		spawn_knife_choice()

# Funções de detecção de área (inalterado)
func _on_homem_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_com_homem = true
		audio_effect.stop()
func _on_homem_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_com_homem = false
		trigger_ambient_event()
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro": pode_interagir_escada = true
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro": pode_interagir_escada = false

# --- MUDANÇA: Lógica de diálogo agora é sequencial ---
func trigger_ambient_event() -> void:
	if not CHORO.is_empty():
		audio_effect.stream = CHORO.pick_random()
		audio_effect.play()

	if not is_ambient_dialog_active and not pode_interagir_com_homem and not DIALOGOS_ALEATORIOS_HOMEM.is_empty():
		is_ambient_dialog_active = true
		$Escudeiro.texture.play("idle")
		# Pega o diálogo da lista usando o nosso novo índice sequencial.
		var dialogo_sequencial = DIALOGOS_ALEATORIOS_HOMEM[ambient_dialog_index]
		
		# Prepara o índice para a PRÓXIMA vez que esta função for chamada.
		ambient_dialog_index += 1
		
		# Se o índice passou do fim da lista (neste caso, se for 3), ele volta para o início (0).
		if ambient_dialog_index >= DIALOGOS_ALEATORIOS_HOMEM.size():
			ambient_dialog_index = 0
		
		# Instancia a caixa de diálogo com a fala sequencial.
		var dialog_box = DIALOG_SYSTEM.instantiate()
		dialog_box.dialog_data = {0: dialogo_sequencial}
		dialog_box.dialog_finished.connect(_on_ambient_dialog_finished)
		add_child(dialog_box)

func _on_ambient_dialog_finished() -> void:
	is_ambient_dialog_active = false

func _on_audio_effect_finished() -> void:
	var random_delay = randf_range(5.0, 10.0)
	print("Próximo evento de ambiente em: %.1f segundos" % random_delay)
	
	await get_tree().create_timer(random_delay).timeout
	trigger_ambient_event()

# Funções de Escolha e Morte (inalterado)
func spawn_knife_choice() -> void:
	var choice_box = CHOICE_BOX_SCENE.instantiate()
	add_child(choice_box)
	choice_box.choice_made.connect(_on_knife_choice_made)
	choice_box.prompt("Pegar a faca?", player)
func _on_knife_choice_made(player_chose_yes: bool) -> void:
	if player_chose_yes:
		die()
	else:
		print("Jogador escolheu NÃO (Não pegar a faca).")
		trigger_ambient_event()
func die() -> void:
	var ds = DIE_SCREEN.instantiate()
	add_child(ds)
	await get_tree().create_timer(10.0).timeout
	get_tree().reload_current_scene()
