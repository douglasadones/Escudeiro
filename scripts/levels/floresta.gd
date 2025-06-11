extends Node2D
class_name Floresta

const DIALOG_SYSTEM: PackedScene = preload("res://scenes/ui/dialog_box.tscn")
const DIE_SCREEN: PackedScene = preload("res://scenes/transicao/die_screen.tscn")

const HOLD_TO_INTERACT_DURATION: float = 1.5

@onready var corvo: AudioStreamPlayer2D = $Corvo
@onready var floresta: AudioStreamPlayer2D = $Floresta
# Interação 1
@onready var nevoa01: Node2D = $Ativar/Nevoa01
@onready var ativar: Node2D = $Ativar
@onready var vibrar_controle: Area2D = $Ativar/VibrarControle
# ##-- ADIÇÃO: Referências para a Interação 2 --##
@onready var nevoa02: Node2D = $Ativar2/Nevoa02
@onready var ativar2: Node2D = $Ativar2
@onready var vibrar_controle_2: Area2D = $Ativar2/VibrarControle2

# ##-- MUDANÇA: Variáveis de controle separadas --##
var pode_interagir_1: bool = false
var pode_interagir_2: bool = false
var is_holding_interact: bool = false
var hold_timer: float = 0.0

var dialogo_1: Dictionary = {
	0: { "title": "Menina do meio", "dialog": "O Velho Jacob está já no banheiro… hi hi hi De novo!" },
	1: { "title": "Velha no lado direito:", "dialog": "Não seja frívola, menina! A água está péssima, tudo é sujeira." },
	2: { "title": "Velha no lado direito:", "dialog": "Os Senhores da Terra mataram nossos filhos pelo aço e agora nos matam pelo veneno e fogo jogado nas terras." },
	3: { "title": "Velha no lado direito:", "dialog": "Jacob é outra vítima de assassinato, assissinato tão vil e desonroso como os oferecidos pelos soldados dos senhores." },
	4: { "title": "Velha no lado direito:", "dialog": "Volte ao trabalho e deixe o pobre Jacob viver sua morte em paz!" },
}

var dialogo_2: Dictionary = {
	0: { "title": "", "dialog": "O Escudeiro tenta a maçaneta da porta do banheiro, mas a encontra firmemente trancada. Ele bate uma vez, de leve." },
	1: { "title": "", "dialog": "(Som vindo de dentro: Um acesso de tosse profunda e úmida, que parece não ter fim.)" },
	2: { "title": "Escudeiro:", "dialog": "[pensamento] O caminho está bloqueado. Pelo som, o Velho Jacob não vai sair daqui tão cedo. Inútil esperar." },
	3: { "title": "Escudeiro:", "dialog": "[pensamento] O sofrimento dele virou um muro. Preciso achar outra rota... e rápido." },
}

var dialogo_3: Dictionary = {
	0: { "title": "Escudeiro:", "dialog": "[pensamento] A porta está fechada. Há um buraco no teto… Quem sabe se eu usar novamente aquilo…." },
}

func _ready() -> void:
	_corvo_loop()
	Music.set_music("res://assets/OST/City/RPG City Theme.wav", "res://assets/OST/City/RPG City Pause Theme.wav")
	Global.foi_pra_floresta = true
	if !Music.tocando:
		Music.play()
		
	# Desativa o grupo 1
	if is_instance_valid(ativar):
		ativar.visible = false
	if is_instance_valid(nevoa01):
		nevoa01.visible = false
		nevoa01.process_mode = Node.PROCESS_MODE_DISABLED
	
	# ##-- ADIÇÃO: Desativa o grupo 2 --##
	if is_instance_valid(ativar2):
		ativar2.visible = false
	if is_instance_valid(nevoa02):
		nevoa02.visible = false
		nevoa02.process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	# ##-- MUDANÇA: Verifica se QUALQUER interação é possível --##
	var pode_interagir_agora = pode_interagir_1 or pode_interagir_2
	if not pode_interagir_agora:
		return

	if Input.is_action_just_pressed("interagir"):
		is_holding_interact = true
		hold_timer = 0.0
		Input.start_joy_vibration(0, 0.7, 0.7, HOLD_TO_INTERACT_DURATION)

	elif is_holding_interact and Input.is_action_pressed("interagir"):
		hold_timer += delta
		
		if hold_timer >= HOLD_TO_INTERACT_DURATION:
			Input.stop_joy_vibration(0)
			# ##-- MUDANÇA: Decide qual névoa ativar --##
			if pode_interagir_1:
				ativar_nevoa1()
			elif pode_interagir_2:
				ativar_nevoa2()
			
			is_holding_interact = false
	
	elif Input.is_action_just_released("interagir"):
		if is_holding_interact:
			Input.stop_joy_vibration(0)
			is_holding_interact = false

func ativar_nevoa1() -> void:
	print("Delay completo! Ativando a névoa 1.")
	
	if is_instance_valid(nevoa01):
		nevoa01.visible = true
		nevoa01.process_mode = Node.PROCESS_MODE_INHERIT

	pode_interagir_1 = false
	
	if is_instance_valid(vibrar_controle):
		vibrar_controle.queue_free()

##-- ADIÇÃO: Função para ativar a névoa 2 --##
func ativar_nevoa2() -> void:
	print("Delay completo! Ativando a névoa 2.")
	
	if is_instance_valid(nevoa02):
		nevoa02.visible = true
		nevoa02.process_mode = Node.PROCESS_MODE_INHERIT

	pode_interagir_2 = false
	
	if is_instance_valid(vibrar_controle_2):
		vibrar_controle_2.queue_free()

# --- Funções Base e Sinais (com poucas alterações) ---

func _on_npc_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		die()

func die() -> void:
	var ds = DIE_SCREEN.instantiate()
	add_child(ds)
	await get_tree().create_timer(10.0).timeout
	get_tree().reload_current_scene()

func _on_floresta_finished() -> void:
	floresta.play()

func _corvo_loop() -> void:
	while true:
		await get_tree().create_timer(8.0).timeout
		corvo.play()
		
func _on_troca_cena_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		Global.current_scene_path = "res://scenes/levels/Caverna/caverna.tscn"
		Global.spawn_pos_escudeiro = Vector2(2850, 160)
		transition_screen.fade_in()
		
func _on_troca_cena_2_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		Global.current_scene_path = "res://scenes/levels/CasaViburno/casa_viburno.tscn"
		Global.spawn_pos_escudeiro = Vector2(1500, 160)
		transition_screen.fade_in()
		
func spawn_dialog(dialog_info: Dictionary) -> void:
	var ds = DIALOG_SYSTEM.instantiate()
	ds.dialog_data = dialog_info
	add_child(ds)

func _on_dialogo_1_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		$Escudeiro.texture.play("idle")
		spawn_dialog(dialogo_1)
		$Dialogo1.queue_free()
		
func _on_dialogo_2_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		$Escudeiro.texture.play("idle")
		spawn_dialog(dialogo_2)
		ativar.visible = true # Ativa o grupo 1
		$Dialogo2.queue_free()

# ##-- MUDANÇA: Renomeado para clareza e controla a flag 1 --##
func _on_vibrar_controle_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_1 = true
		print("Pode interagir com a névoa 1.")

# ##-- MUDANÇA: Renomeado para clareza e controla a flag 1 --##
func _on_vibrar_controle_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_1 = false
		print("Não pode mais interagir com a névoa 1.")

# --- Novas funções para a interação 2 ---
func _on_dialogo_3_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		$Escudeiro.texture.play("idle")
		spawn_dialog(dialogo_3)
		ativar2.visible = true # Ativa o grupo 2
		$Dialogo3.queue_free()

# ##-- ADIÇÃO: Controla a flag 2 --##
func _on_vibrar_controle_2_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_2 = true
		print("Pode interagir com a névoa 2.")

# ##-- ADIÇÃO: Controla a flag 2 --##
func _on_vibrar_controle_2_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_2 = false
		print("Não pode mais interagir com a névoa 2.")
