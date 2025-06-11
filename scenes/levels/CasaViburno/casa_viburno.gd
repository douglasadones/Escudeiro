extends Node2D

# Configurações
@export var death_screen_duration: float = 9.0
@export var die_screen_scene = preload("res://scenes/transicao/die_screen.tscn")
const NEVOA02: PackedScene = preload("res://scenes/levels/CasaViburno/nevoas/nevoa_02_viburno.tscn")
const NEVOA03: PackedScene = preload("res://scenes/levels/CasaViburno/nevoas/nevoa_03_viburno.tscn")
const NEVOA04: PackedScene = preload("res://scenes/levels/CasaViburno/nevoas/nevoa_04_viburno.tscn")

# Referências
@onready var player = get_node("Escudeiro")

# Estado do jogo
var game_over: bool = false

var nevoa02: Node2D
var nevoa03: Node2D
var nevoa04: Node2D
var zona_interacao_nevoa: int = 0

func _ready():
	Music.set_music("res://assets/OST/Battle/Generic Battle.wav", "res://assets/OST/City/RPG City Pause Theme.wav")
	#Global.foi_pra_floresta = true
	if !Music.tocando:
		Music.play()
	# Adiciona o player ao grupo se não estiver
	if player:
		player.add_to_group("Player")
	
	# Conecta sinal de morte do player se existir
	if player and player.has_signal("player_died"):
		player.player_died.connect(_on_player_died)
	
	# Timer para verificar se player morreu
	var check_timer = Timer.new()
	add_child(check_timer)
	check_timer.wait_time = 0.1
	check_timer.timeout.connect(_check_player_death)
	check_timer.start()
	
	if player:
		player.hold_completed.connect(_on_player_hold_completed)
		player.hold_cancelled.connect(_on_player_hold_cancelled)

func _on_player_hold_completed():
	match zona_interacao_nevoa:
		1:
			ativar_nevoa02()
		2:
			ativar_nevoa03()
		3:
			ativar_nevoa04()
		4:
			pass #coloca aqui a funcao de transição pra cena final

func _on_player_hold_cancelled():
	print("Porta: Player cancelou o hold!")
func _check_player_death():
	if game_over:
		return
	
	# Verifica se player morreu de diferentes formas
	if not player or not is_instance_valid(player):
		_on_player_died()
	elif player.is_dead:
		_on_player_died()
	elif player.health <= 0:
		_on_player_died()

func ativar_nevoa02() -> void:

	# Cria a névoa 01 apenas se ela ainda não existir
	if not is_instance_valid(nevoa02):
		nevoa02 = NEVOA02.instantiate()
		add_child(nevoa02)
		remove_child($Nevoa01Viburno)
	
	# Desativa a interação para não criar a névoa de novo sem sair e entrar na área
	zona_interacao_nevoa = 0
func ativar_nevoa03() -> void:
	if is_instance_valid(nevoa02):
		nevoa02.queue_free()
		#nevoa02 = null

	# Cria a névoa 01 apenas se ela ainda não existir
	if not is_instance_valid(nevoa03):
		nevoa03 = NEVOA03.instantiate()
		add_child(nevoa03)
	
	# Desativa a interação para não criar a névoa de novo sem sair e entrar na área
	zona_interacao_nevoa = 0
	
func ativar_nevoa04() -> void:
	if is_instance_valid(nevoa03):
		nevoa03.queue_free()
		#nevoa03 = null

	# Cria a névoa 01 apenas se ela ainda não existir
	if not is_instance_valid(nevoa04):
		nevoa04 = NEVOA04.instantiate()
		add_child(nevoa04)
	
	# Desativa a interação para não criar a névoa de novo sem sair e entrar na área
	zona_interacao_nevoa = 0
	

func _on_player_died():
	if game_over:
		return
	
	game_over = true
	
	# Mostra tela de morte se configurada
	if die_screen_scene:
		var death_screen = die_screen_scene.instantiate()
		add_child(death_screen)
	
	# Aguarda e recarrega a cena
	await get_tree().create_timer(death_screen_duration).timeout
	get_tree().reload_current_scene()

func _on_interacao_1_body_entered(body: Node2D) -> void:
	if(body.name == "Escudeiro") and has_node("Nevoa01Viburno"):
		
		zona_interacao_nevoa = 1


func _on_interacao_2_body_entered(body: Node2D) -> void:
	if(body.name == "Escudeiro") and is_instance_valid(nevoa02):
		
		zona_interacao_nevoa = 2


func _on_interacao_3_body_entered(body: Node2D) -> void:
	if(body.name == "Escudeiro") and is_instance_valid(nevoa03):
		
		zona_interacao_nevoa = 3

func _on_interacao_4_body_entered(body: Node2D) -> void:
	if(body.name == "Escudeiro"):
		zona_interacao_nevoa = 4

func _on_interacao_1_body_exited(body: Node2D) -> void:
	if(body.name == "Escudeiro"):
		zona_interacao_nevoa = 0


func _on_interacao_2_body_exited(body: Node2D) -> void:
	if(body.name == "Escudeiro"):
		zona_interacao_nevoa = 0


func _on_interacao_3_body_exited(body: Node2D) -> void:
	if(body.name == "Escudeiro"):
		zona_interacao_nevoa = 0

func _on_interacao_4_body_exited(body: Node2D) -> void:
	if(body.name == "Escudeiro"):
		zona_interacao_nevoa = 0
