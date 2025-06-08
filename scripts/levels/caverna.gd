extends Node2D
class_name Caverna

# --- CONSTANTES ---
const DIALOG_SYSTEM: PackedScene = preload("res://scenes/ui/dialog_box.tscn")
const NEVOA01: PackedScene = preload("res://scenes/levels/Caverna/nevoa/nevoa_01.tscn")
const NEVOA02: PackedScene = preload("res://scenes/levels/Caverna/nevoa/nevoa_02.tscn")

# --- @ONREADY ---
@onready var place_holder: Area2D = $PlaceHolder

# --- @EXPORT ---
@export_category("Variables")
@export var scene_path: String

# --- VARIÁVEIS ---
var pode_interagir_dialogo: bool = false # Para o diálogo inicial
var motor_active := false
var nevoa01: Node2D
var nevoa02: Node2D
var vibration_area_count := 0

# NOVO: Variável para controlar qual névoa pode ser ativada.
# 0 = Nenhuma, 1 = Pode ativar a névoa 1, 2 = Pode ativar a névoa 2
var zona_interacao_nevoa: int = 0

var dialogo_inicial: Dictionary = {
	0: {
		"title": "Garrafa de Vinho Forte​",
		"dialog": "Vinho adulterado, mais alcoólico do que deveria. Use-o para evitar ser tomado pelo terror.",
	},
}

func _ready() -> void:
	# ... (A função _ready() continua a mesma de antes)
	Global.current_scene_path = scene_path
	var escudeiro = get_node("Escudeiro")
	
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
	
	if !Music.tocando:
		Music.play()
	
	Pausa.enable_pause_menu()


func _process(delta: float) -> void:
	# Lógica para o diálogo do place_holder (inalterada)
	if pode_interagir_dialogo and Input.is_action_just_pressed("interagir"):
		spawn_dialog(dialogo_inicial)
		place_holder.queue_free()
		pode_interagir_dialogo = false # Desativa após usar
		return # Retorna para não ativar a névoa ao mesmo tempo

	# NOVA LÓGICA: Checa se o botão de interação foi pressionado
	if Input.is_action_just_pressed("interagir"):
		# Usa um 'match' (similar a 'switch') para decidir o que fazer
		match zona_interacao_nevoa:
			1: # Se estiver na zona da névoa 1
				ativar_nevoa01()
			2: # Se estiver na zona da névoa 2
				ativar_nevoa02()

# --- Funções de Ativação (separadas para mais clareza) ---

func ativar_nevoa01() -> void:
	print("Ativando Névoa 01")
	# Remove a névoa 02 se ela existir
	if is_instance_valid(nevoa02):
		nevoa02.queue_free()
		nevoa02 = null

	# Cria a névoa 01 apenas se ela ainda não existir
	if not is_instance_valid(nevoa01):
		nevoa01 = NEVOA01.instantiate()
		add_child(nevoa01)
	
	# Desativa a interação para não criar a névoa de novo sem sair e entrar na área
	zona_interacao_nevoa = 0

func ativar_nevoa02() -> void:
	print("Ativando Névoa 02")
	# Remove a névoa 01 se ela existir
	if is_instance_valid(nevoa01):
		nevoa01.queue_free()
		nevoa01 = null

	# Cria a névoa 02 apenas se ela ainda não existir
	if not is_instance_valid(nevoa02):
		nevoa02 = NEVOA02.instantiate()
		add_child(nevoa02)
	
	# Desativa a interação para não criar a névoa de novo
	zona_interacao_nevoa = 0

# --- Funções de Sinais das Áreas (Agora só habilitam a interação) ---

func _on_place_holder_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_dialogo = true

func _on_place_holder_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir_dialogo = false

func _on_vibrar_controle_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count += 1
		if not motor_active:
			motor_active = true
			continuous_vibration_loop()
		
		# MODIFICADO: Apenas define que a zona 1 está ativa para interação
		zona_interacao_nevoa = 1


func _on_vibrar_controle_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count -= 1
		if vibration_area_count <= 0:
			motor_active = false
			Input.stop_joy_vibration(0)
			vibration_area_count = 0
		
		# MODIFICADO: Desabilita a interação ao sair da zona
		if zona_interacao_nevoa == 1:
			zona_interacao_nevoa = 0


func _on_vibrar_controle_2_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count += 1
		if not motor_active:
			motor_active = true
			continuous_vibration_loop()
			
		# MODIFICADO: Apenas define que a zona 2 está ativa para interação
		zona_interacao_nevoa = 2



func _on_vibrar_controle_2_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		vibration_area_count -= 1
		if vibration_area_count <= 0:
			motor_active = false
			Input.stop_joy_vibration(0)
			vibration_area_count = 0
		
		# MODIFICADO: Desabilita a interação ao sair da zona
		if zona_interacao_nevoa == 2:
			zona_interacao_nevoa = 0

# --- Funções de suporte (inalteradas) ---
# ... (spawn_dialog, continuous_vibration_loop, _on_troca_cena_body_entered)
func spawn_dialog(dialog_info: Dictionary) -> void:
	var ds = DIALOG_SYSTEM.instantiate()
	ds.dialog_data = dialog_info
	add_child(ds)

func continuous_vibration_loop() -> void:
	if not motor_active: return
	Input.start_joy_vibration(0, 0.2, 0.2, 0.5)
	await get_tree().create_timer(0.5).timeout
	continuous_vibration_loop()

func _on_troca_cena_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		Global.current_scene_path = "res://scenes/levels/Adega/adega.tscn"
