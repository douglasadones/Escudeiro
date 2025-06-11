extends Node2D
class_name Caverna

const DIALOG_SYSTEM: PackedScene = preload("res://scenes/ui/dialog_box.tscn")
const DIE_SCREEN: PackedScene = preload("res://scenes/transicao/die_screen.tscn")
# Duração da interação de segurar
const HOLD_TO_INTERACT_DURATION: float = 1.0

@onready var place_holder: Area2D = $LevelDesign/PlaceHolder
@onready var escudeiro_sprite: AnimatedSprite2D = $Escudeiro/Texture
@onready var nevoa01: Node2D = $Labirinto/Nevoa01
@onready var nevoa02: Node2D = $Labirinto/Nevoa02
@onready var nevoa03: Node2D = $Labirinto/Nevoa03
@onready var nevoa04: Node2D = $Labirinto/Nevoa04
@onready var nevoa05: Node2D = $Labirinto/Nevoa05
@onready var nevoa_3_5: Node2D = $Labirinto/Nevoa3_5
@onready var audio_morcego: AudioStreamPlayer2D = $Morcego3/audio_morcego
@onready var morcego: CharacterBody2D = $Morcego
# @onready var hold_indicator: TextureProgressBar = $HoldIndicator

@export_category("Variables")
@export var scene_path: String

var pode_interagir_dialogo: bool = false
var pode_interagir_nevoa1: bool = false
var pode_interagir_nevoa2: bool = false
var pode_interagir_nevoa3: bool = false
var pode_interagir_nevoa4: bool = false
var pode_interagir_nevoa5: bool = false
var pode_remover_nevoa5: bool = false

# Variáveis para controlar a mecânica de segurar o botão
var hold_timer: float = 0.0
var is_holding_interact: bool = false

var dialogo_inicial: Dictionary = {
	0: { "title": "Garrafa de Vinho Forte​", "dialog": "Vinho adulterado..." },
}

var dialogo_2: Dictionary = {
	0: { "title": "Escudeiro", "dialog": "[pensamento] Não consigo passar… Por que sinto a taça ficando mais fria… Será que?" },
}

var dialogo_3: Dictionary = {
	0: { "title": "Escudeiro", "dialog": "[pensamento] Agora posso atravessar… acho…? Eles caminharam na neblina também… Será que eu… bem…" },
}

var dialogo_4: Dictionary = {
	0: { "title": "Escudeiro", "dialog": "[pensamento] Terei que usar a taça novamente" },
}

var dialogo_5: Dictionary = {
	0: { "title": "", "dialog": "Seu coração é compatível com a taça… mas o quanto será?" },
}

var dialogo_6: Dictionary = {
	0: { "title": "", "dialog": "A taça faz a neblina tomar muitas formas… para contribuir com que nela bebe… e para…" },
}

func _ready() -> void:
	Global.current_scene_path = scene_path
	var escudeiro = get_node("Escudeiro")
	
	if Global.foi_para_adega:
		if is_instance_valid(place_holder):
			place_holder.queue_free()
		ativar_nevoa04()
	
	if Global.primeira_vez_caverna:
		escudeiro.position = Vector2(100, 160)
		Global.primeira_vez_caverna = false
	else:
		escudeiro.position = Global.spawn_pos_escudeiro
	
	if Global.foi_pra_floresta:
		Music.set_music("res://assets/OST/Cave/Cave theme loop.wav", "res://assets/OST/Cave/cave theme pause loop.wav")
		Global.foi_pra_floresta = false
		if escudeiro.has_node("Sprite2D"):
			escudeiro.get_node("Sprite2D").flip_h = true
		nevoa01.queue_free()
		nevoa02.queue_free()
		nevoa03.queue_free()
		nevoa_3_5.queue_free()
		nevoa04.queue_free()
		nevoa05.queue_free()
	
	if !Music.tocando:
		Music.play()
	
	Pausa.enable_pause_menu()
	
	if is_instance_valid(nevoa01):
		nevoa01.visible = false
		nevoa01.process_mode = Node.PROCESS_MODE_DISABLED
	if is_instance_valid(nevoa02):
		nevoa02.visible = false; nevoa02.process_mode = Node.PROCESS_MODE_DISABLED
	if is_instance_valid(nevoa03):
		nevoa03.visible = false; nevoa03.process_mode = Node.PROCESS_MODE_DISABLED
	if not nevoa04.is_visible_in_tree():
		nevoa04.visible = false; nevoa04.process_mode = Node.PROCESS_MODE_DISABLED
	if is_instance_valid(nevoa05):
		nevoa05.visible = false; nevoa05.process_mode = Node.PROCESS_MODE_DISABLED
	if is_instance_valid(nevoa_3_5):
		nevoa_3_5.visible = false; nevoa_3_5.process_mode = Node.PROCESS_MODE_DISABLED

# Função _process modificada para controlar a interação e a vibração
func _process(delta: float) -> void:
	# Lógica de diálogo com clique simples
	if pode_interagir_dialogo and Input.is_action_just_pressed("interagir"):
		spawn_dialog(dialogo_inicial)
		if is_instance_valid(place_holder):
			place_holder.queue_free()
		pode_interagir_dialogo = false
		return

	# Verifica se o jogador pode interagir com qualquer névoa
	var pode_interagir_com_qualquer_nevoa = pode_interagir_nevoa1 or pode_interagir_nevoa2 or pode_interagir_nevoa3 or pode_interagir_nevoa4 or pode_interagir_nevoa5 or pode_remover_nevoa5
	
	# 1. Se o jogador APERTA o botão de interação e PODE interagir
	if pode_interagir_com_qualquer_nevoa and Input.is_action_just_pressed("interagir"):
		is_holding_interact = true
		hold_timer = 0.0
		# INICIA A VIBRAÇÃO com a mesma duração do carregamento
		Input.start_joy_vibration(0, 0.7, 0.7, HOLD_TO_INTERACT_DURATION)

	# 2. Se o jogador está SEGURANDO o botão
	elif is_holding_interact and Input.is_action_pressed("interagir"):
		hold_timer += delta # Incrementa o temporizador
		
		# Se o tempo de segurar foi atingido
		if hold_timer >= HOLD_TO_INTERACT_DURATION:
			Input.stop_joy_vibration(0) # Garante que a vibração pare
			
			# Executa a ação da névoa correspondente
			if pode_remover_nevoa5: remover_nevoa05()
			elif pode_interagir_nevoa5: ativar_nevoa05()
			elif pode_interagir_nevoa4: ativar_nevoa_3_5()
			elif pode_interagir_nevoa3: ativar_nevoa03()
			elif pode_interagir_nevoa2: ativar_nevoa02()
			elif pode_interagir_nevoa1: ativar_nevoa01()
			
			# Reseta o estado da interação
			is_holding_interact = false
	
	# 3. Se o jogador SOLTA o botão antes de completar, cancela a ação
	elif Input.is_action_just_released("interagir"):
		if is_holding_interact:
			Input.stop_joy_vibration(0) # PARA a vibração
			is_holding_interact = false


# --- FUNÇÕES DE ATIVAÇÃO DE NÉVOA ---

func ativar_nevoa01() -> void:
	print("Ativando Névoa 01")
	nevoa01.visible = true
	nevoa01.process_mode = Node.PROCESS_MODE_INHERIT
	nevoa02.visible = false
	nevoa02.process_mode = Node.PROCESS_MODE_DISABLED
	pode_interagir_nevoa1 = false
	spawn_dialog(dialogo_3)
	$Labirinto/VibrarControle.queue_free()
	
func ativar_nevoa02() -> void:
	print("Ativando Névoa 02")
	nevoa02.visible = true
	nevoa02.process_mode = Node.PROCESS_MODE_INHERIT
	spawn_dialog(dialogo_5)
	if is_instance_valid(nevoa01):
		nevoa01.queue_free()
	pode_interagir_nevoa2 = false

func ativar_nevoa03() -> void:
	print("Ativando Névoa 03")
	nevoa03.visible = true
	nevoa03.process_mode = Node.PROCESS_MODE_INHERIT
	nevoa02.visible = false
	nevoa02.process_mode = Node.PROCESS_MODE_DISABLED
	pode_interagir_nevoa3 = false
	spawn_dialog(dialogo_6)

func ativar_nevoa04() -> void:
	print("Ativando Névoa 04")
	nevoa04.visible = true
	nevoa04.process_mode = Node.PROCESS_MODE_INHERIT
	nevoa03.visible = false
	nevoa03.process_mode = Node.PROCESS_MODE_DISABLED
	nevoa02.visible = false
	nevoa02.process_mode = Node.PROCESS_MODE_DISABLED

func ativar_nevoa_3_5() -> void:
	print("Ativando Névoa 3_5")
	nevoa_3_5.visible = true
	nevoa_3_5.process_mode = Node.PROCESS_MODE_INHERIT
	nevoa03.visible = false
	nevoa03.process_mode = Node.PROCESS_MODE_DISABLED
	pode_interagir_nevoa4 = false
	if get_node_or_null("Labirinto/VibrarControle4"):
		$Labirinto/VibrarControle4.queue_free()

func ativar_nevoa05() -> void:
	print("Ativando Névoa 05")
	nevoa05.visible = true
	nevoa05.process_mode = Node.PROCESS_MODE_INHERIT
	nevoa04.visible = false
	nevoa04.process_mode = Node.PROCESS_MODE_DISABLED
	pode_interagir_nevoa5 = false

func remover_nevoa05() -> void:
	print("Removendo Névoa 05")
	if is_instance_valid(nevoa05):
		nevoa05.queue_free()
	pode_remover_nevoa5 = false
	if get_node_or_null("Labirinto/VibrarControle6"):
		$Labirinto/VibrarControle6.queue_free()

func spawn_dialog(dialog_info: Dictionary) -> void:
	var ds = DIALOG_SYSTEM.instantiate()
	ds.dialog_data = dialog_info
	add_child(ds)

# --- SINAIS (Signals) ---

# Sinais de troca de cena e diálogo permanecem iguais
func _on_troca_cena_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		Global.current_scene_path = "res://scenes/levels/Floresta/floresta.tscn"
		transition_screen.fade_in()

func _on_place_holder_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_dialogo = true

func _on_place_holder_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_dialogo = false

func _on_adega_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		Global.foi_para_adega = true
		Global.current_scene_path = "res://scenes/levels/Adega/adega.tscn"
		transition_screen.fade_in()

# Sinais de controle de vibração foram simplificados
func _on_vibrar_controle_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_nevoa1 = true

func _on_vibrar_controle_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_nevoa1 = false

func _on_vibrar_controle_2_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_nevoa2 = true

func _on_vibrar_controle_2_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_nevoa2 = false

func _on_vibrar_controle_3_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_nevoa3 = true

func _on_vibrar_controle_3_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_nevoa3 = false
		
func _on_vibrar_controle_4_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_nevoa4 = true

func _on_vibrar_controle_4_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_nevoa4 = false

func _on_vibrar_controle_5_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_nevoa5 = true

func _on_vibrar_controle_5_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_nevoa5 = false

func _on_vibrar_controle_6_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_remover_nevoa5 = true

func _on_vibrar_controle_6_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_remover_nevoa5 = false

# Funções de morte e áudio permanecem iguais
func die() -> void:
	var ds = DIE_SCREEN.instantiate()
	add_child(ds)
	await get_tree().create_timer(10.0).timeout
	get_tree().reload_current_scene()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		die()

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		die()

func _on_area_2d_3_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		die()

func _on_area_2d_nevoa_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		die()

func _on_audio_morcego_finished() -> void:
	await get_tree().create_timer(8.0).timeout
	audio_morcego.play()

# Sinais de mensagens de diálogo permanecem iguais
func _on_msg_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		$Escudeiro.texture.play("idle")
		spawn_dialog(dialogo_2)
		$Labirinto/VibrarControle/Texture.visible = true
		$Msg.queue_free()
func _on_msg_2_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		$Escudeiro.texture.play("idle")
		spawn_dialog(dialogo_2)
		$Msg2.queue_free()
