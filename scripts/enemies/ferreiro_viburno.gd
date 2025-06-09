extends CharacterBody2D

# Configurações de movimento
@export var speed: float = 72.0
@export var patrol_distance: float = 9900.0
@export var direction: int = 1 
var andando = false
var atirar = false
# Configurações de arremesso
@export var throw_range: float = 300.0
@export var throw_cooldown: float = 2.0
@export var projectile_scene = preload("res://scenes/enemies/projetil/faca.tscn")  
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
@onready var throw_point = $Marker2D_cima  # Ponto de onde sairão os projéteis

# Controle de estado
var player: Node2D
var start_position: Vector2
var can_throw: bool = true
var is_dead: bool = false

func _ready():
	start_position = global_position
	
	# Configura o timer de arremesso
	throw_timer.wait_time = throw_cooldown
	throw_timer.timeout.connect(_on_throw_timer_timeout)
	
	player = get_tree().get_first_node_in_group("Player")
	
	add_to_group("enemies")

func _physics_process(delta):
	if is_dead:
		return
	
	
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
	if is_on_wall() or not is_floor_ahead():
		direction *= -1
		flip_sprite()

func is_floor_ahead() -> bool:
	# Verifica se há chão à frente para não cair
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position + Vector2(direction * 32, 0),
		global_position + Vector2(direction * 32, 64)
	)
	var result = space_state.intersect_ray(query)
	return result.size() > 0

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
	if not projectile_scene or not can_throw:
		return
	
	can_throw = false
	throw_timer.start()
	
	# Instancia o projétil
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

func take_damage(amount: int):
	if is_dead:
		return
	
	health -= amount
	
	# Efeito visual de dano (opcional)
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	if health <= 0:
		die()

func die():
	is_dead = true
	velocity = Vector2.ZERO
	
	# Animação de morte (opcional)
	var tween = create_tween()
	tween.parallel().tween_property(self, "modulate:a", 0.0, 1.0)
	tween.parallel().tween_property(self, "scale", Vector2(1.2, 0.8), 0.5)
	tween.tween_callback(queue_free)

# Função para detectar colisão com o player
func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

# Função para ser chamada quando o inimigo colide com algo
func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)


func _on_timer_andar_timeout() -> void:
	andando = true
	atirar = true
