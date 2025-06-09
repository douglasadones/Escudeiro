extends Node2D

# Configurações
@export var death_screen_duration: float = 3.0
@export var die_screen_scene = preload("res://scenes/transicao/die_screen.tscn")

# Referências
@onready var player = get_node("Escudeiro")  # Ajuste o caminho conforme sua estrutura

# Estado do jogo
var game_over: bool = false

func _ready():
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

func _on_player_died():
	if game_over:
		return
	
	game_over = true
	print("Player morreu! Recarregando cena em ", death_screen_duration, " segundos...")
	
	# Mostra tela de morte se configurada
	if die_screen_scene:
		var death_screen = die_screen_scene.instantiate()
		add_child(death_screen)
	
	# Aguarda e recarrega a cena
	await get_tree().create_timer(death_screen_duration).timeout
	get_tree().reload_current_scene()
