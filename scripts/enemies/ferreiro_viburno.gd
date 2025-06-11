extends CharacterBody2D

# Configurações de movimento
@export var speed: float = 72.0
@export var patrol_distance: float = 9900.0
@export var direction: int = 1 

# Configurações de arremesso
@export var throw_range: float = 360.0
@export var throw_cooldown: float = 2.1
@export var projectiles_scenes = [
	preload("res://scenes/enemies/projetil/faca.tscn"),
	preload("res://scenes/enemies/projetil/martelo.tscn")
]
@export var throw_force: float = 900.0
@export var throw_angle: float = 9.0  
@export var projectile_kills_player = true  
@export var DIE_SCREEN = preload("res://scenes/transicao/die_screen.tscn")  

# Configurações do inimigo
@export var health: int = 100
@export var damage: int = 20

# Referências
@onready var sprite = $AnimatedSprite2D
@onready var throw_timer = $Timer_tiro_delay
@onready var throw_point = $Marker2D_cima

# Controle de estado
var player: Node2D
var start_position: Vector2
var can_throw: bool = true
var andando = false
var atirar = false

func _ready():
	start_position = global_position
	
	# Configura o timer de arremesso
	throw_timer.wait_time = throw_cooldown
	throw_timer.timeout.connect(_on_throw_timer_timeout)
	
	player = get_tree().get_first_node_in_group("Player")
	
	add_to_group("enemies")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	# Movimento de patrulha
	if andando:
		patrol_movement()
	
	# Verifica se pode arremessar no player
	if atirar:
		check_throw_opportunity()
	
	# Move o personagem
	move_and_slide()

func patrol_movement():
	$AnimatedSprite2D.play("walk")
	# Calcula a distância percorrida desde o ponto inicial
	var distance_from_start = global_position.x - start_position.x
	
	# Inverte a direção se chegou no limite da patrulha
	if abs(distance_from_start) >= patrol_distance:
		direction *= -1
		flip_sprite()
	
	# Move na direção atual
	velocity.x = direction * speed
	
	# Verifica se há uma parede ou buraco à frente
	#if is_on_wall():
		#direction *= -1
		#flip_sprite()

func flip_sprite():
	# Vira o sprite baseado na direção
	if sprite:
		sprite.flip_h = direction < 0

func check_throw_opportunity():
	if not player or not can_throw:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Se o player está dentro do alcance de arremesso
	if distance_to_player <= throw_range:
		throw_projectile()

func throw_projectile():
	if not projectiles_scenes or not can_throw:
		return
	
	can_throw = false
	throw_timer.start()
	
	# Instancia o projétil
	var index = randi() % projectiles_scenes.size()
	var projectile_scene = projectiles_scenes[index]
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	
	
	
	# Posiciona o projétil no ponto de arremesso
	if throw_point:
		projectile.global_position = throw_point.global_position
	else:
		projectile.global_position = global_position + Vector2(0, -20)
	
	# Calcula direção para o player
	var direction_to_player = (player.global_position - projectile.global_position).normalized()
	
	# Aplica ângulo de arremesso
	var throw_direction = direction_to_player.rotated(deg_to_rad(throw_angle))
	
	# Configura o projétil
	if projectile.has_method("set_direction"):
		projectile.set_direction(throw_direction * throw_force)
	elif projectile.has_method("set_velocity"):
		projectile.set_velocity(throw_direction * throw_force)
	elif projectile.has_method("set_force"):
		projectile.set_force(throw_direction * throw_force)
	
	# Configuração adicional do projétil se disponível
	if projectile.has_method("setup_projectile"):
		projectile.setup_projectile(damage, 5.0, 2)
	
	# Configura se o projétil mata o player
	if projectile.kills_player:
		projectile.kills_player = projectile_kills_player
	
	# Passa a cena de morte para o projétil se configurada
	if DIE_SCREEN and projectile.DIE_SCREEN:
		projectile.DIE_SCREEN = DIE_SCREEN

func _on_throw_timer_timeout():
	can_throw = true

func _on_timer_andar_timeout() -> void:
	andando = true
	atirar = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.name == "sikiana" or body.name == "Area2D":
		direction *= -1
		flip_sprite()
