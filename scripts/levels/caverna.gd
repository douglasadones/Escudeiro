extends Node2D
class_name Caverna

const DIALOG_SYSTEM: PackedScene = preload("res://scenes/ui/dialog_box.tscn")
const DIE_SCREEN: PackedScene = preload("res://scenes/transicao/die_screen.tscn")
# NOVO: Constante para a duração da interação de segurar
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
# Se você decidir adicionar um indicador visual, descomente a linha abaixo
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

var motor_active := false
var vibration_area_count := 0
# NOVO: Variáveis para controlar a mecânica de segurar o botão
var hold_timer: float = 0.0
var is_holding_interact: bool = false

var dialogo_inicial: Dictionary = {
	0: { "title": "Garrafa de Vinho Forte​", "dialog": "Vinho adulterado..." },
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

# NOVO: A função _process foi substituída para adicionar a lógica de "segurar"
func _process(delta: float) -> void:
	# A lógica de diálogo continua separada e com clique simples
	if pode_interagir_dialogo and Input.is_action_just_pressed("interagir"):
		spawn_dialog(dialogo_inicial)
		if is_instance_valid(place_holder):
			place_holder.queue_free()
		pode_interagir_dialogo = false
		return

	# Verifica se o jogador está em QUALQUER zona de interação com névoa
	var pode_interagir_com_qualquer_nevoa = pode_interagir_nevoa1 or pode_interagir_nevoa2 or pode_interagir_nevoa3 or pode_interagir_nevoa4 or pode_interagir_nevoa5 or pode_remover_nevoa5
	
	# 1. Se o jogador APERTA o botão de interação e PODE interagir
	if pode_interagir_com_qualquer_nevoa and Input.is_action_just_pressed("interagir"):
		is_holding_interact = true
		hold_timer = 0.0
		# Se você tiver um indicador visual, mostre-o aqui:
		# hold_indicator.visible = true
		# hold_indicator.value = 0

	# 2. Se o jogador está SEGURANDO o botão
	elif is_holding_interact and Input.is_action_pressed("interagir"):
		hold_timer += delta # Aumenta o contador
		# Se você tiver um indicador visual, atualize-o aqui:
		# hold_indicator.value = (hold_timer / HOLD_TO_INTERACT_DURATION) * 100
		
		# Se o tempo foi atingido
		if hold_timer >= HOLD_TO_INTERACT_DURATION:
			# Executa a ação correta baseado na zona em que o jogador está
			if pode_remover_nevoa5:
				remover_nevoa05()
			elif pode_interagir_nevoa5:
				ativar_nevoa05()
			elif pode_interagir_nevoa4:
				ativar_nevoa_3_5()
			elif pode_interagir_nevoa3:
				ativar_nevoa03()
			elif pode_interagir_nevoa2:
				ativar_nevoa02()
			elif pode_interagir_nevoa1:
				ativar_nevoa01()
			
			# Reseta o estado para evitar múltiplas ativações
			is_holding_interact = false
			# Se você tiver um indicador visual, esconda-o aqui:
			# hold_indicator.visible = false
	
	# 3. Se o jogador SOLTA o botão, cancela tudo
	elif Input.is_action_just_released("interagir"):
		is_holding_interact = false
		# Se você tiver um indicador visual, esconda-o aqui:
		# hold_indicator.visible = false
		# hold_indicator.value = 0

# O RESTO DO SEU CÓDIGO PERMANECE EXATAMENTE IGUAL

func ativar_nevoa01() -> void:
	print("Ativando Névoa 01")
	nevoa01.visible = true
	nevoa01.process_mode = Node.PROCESS_MODE_INHERIT
	nevoa02.visible = false
	nevoa02.process_mode = Node.PROCESS_MODE_DISABLED
	pode_interagir_nevoa1 = false
	$Labirinto/VibrarControle.queue_free()
	
func ativar_nevoa02() -> void:
	print("Ativando Névoa 02")
	nevoa02.visible = true
	nevoa02.process_mode = Node.PROCESS_MODE_INHERIT
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

func continuous_vibration_loop() -> void:
	if not motor_active:
		return
	Input.start_joy_vibration(0, 0.2, 0.2, 0.5)
	await get_tree().create_timer(0.5).timeout
	continuous_vibration_loop()

func _on_troca_cena_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		Global.current_scene_path = "res://scenes/levels/Floresta/floresta.tscn"
		transition_screen.cap03()

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

func _on_vibrar_controle_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count += 1
		if not motor_active:
			motor_active = true
			continuous_vibration_loop()
		pode_interagir_nevoa1 = true

func _on_vibrar_controle_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count -= 1
		if vibration_area_count <= 0:
			motor_active = false
			Input.stop_joy_vibration(0)
			vibration_area_count = 0
		pode_interagir_nevoa1 = false

func _on_vibrar_controle_2_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count += 1
		if not motor_active:
			motor_active = true
			continuous_vibration_loop()
		pode_interagir_nevoa2 = true

func _on_vibrar_controle_2_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count -= 1
		if vibration_area_count <= 0:
			motor_active = false
			Input.stop_joy_vibration(0)
			vibration_area_count = 0
		pode_interagir_nevoa2 = false

func _on_vibrar_controle_3_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count += 1
		if not motor_active:
			motor_active = true
			continuous_vibration_loop()
		pode_interagir_nevoa3 = true

func _on_vibrar_controle_3_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count -= 1
		if vibration_area_count <= 0:
			motor_active = false
			Input.stop_joy_vibration(0)
			vibration_area_count = 0
		pode_interagir_nevoa3 = false
		
func _on_vibrar_controle_4_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count += 1
		if not motor_active:
			motor_active = true
			continuous_vibration_loop()
		pode_interagir_nevoa4 = true

func _on_vibrar_controle_4_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count -= 1
		if vibration_area_count <= 0:
			motor_active = false
			Input.stop_joy_vibration(0)
			vibration_area_count = 0
		pode_interagir_nevoa4 = false

func _on_vibrar_controle_5_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count += 1
		if not motor_active:
			motor_active = true
			continuous_vibration_loop()
		pode_interagir_nevoa5 = true

func _on_vibrar_controle_5_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count -= 1
		if vibration_area_count <= 0:
			motor_active = false
			Input.stop_joy_vibration(0)
			vibration_area_count = 0
		pode_interagir_nevoa5 = false

func _on_vibrar_controle_6_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count += 1
		if not motor_active:
			motor_active = true
			continuous_vibration_loop()
		pode_remover_nevoa5 = true

func _on_vibrar_controle_6_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count -= 1
		if vibration_area_count <= 0:
			motor_active = false
			Input.stop_joy_vibration(0)
			vibration_area_count = 0
		pode_remover_nevoa5 = false

func die() -> void :
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
