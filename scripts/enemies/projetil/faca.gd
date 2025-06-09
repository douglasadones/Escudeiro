extends RigidBody2D

# Configurações do projétil
@export var damage: int = 15
@export var lifetime: float = 5.0  # Tempo antes de se destruir automaticamente
@export var bounce_count: int = 2  # Quantas vezes pode quicar antes de se destruir
@export var min_velocity_to_damage: float = 50.0  # Velocidade mínima para causar dano
@export var kills_player = true  # Se verdadeiro, mata o player instantaneamente
@export var DIE_SCREEN = preload("res://scenes/transicao/die_screen.tscn")  # Arraste a cena de morte aqui no inspector

# Controle interno
var current_bounces: int = 0
var has_hit_player: bool = false
var is_destroyed: bool = false

# Referências
@onready var sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var lifetime_timer = $LifetimeTimer

func _ready():
	# Configura o timer de vida útil
	lifetime_timer.wait_time = lifetime
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	lifetime_timer.start()
	
	# Conecta sinal de colisão física
	body_entered.connect(_on_body_entered)
	
	# Configura propriedades do RigidBody2D
	gravity_scale = 1.0
	lock_rotation = false
	contact_monitor = true  # Necessário para detectar colisões
	max_contacts_reported = 10  # Máximo de contatos reportados
	
	# Adiciona ao grupo de projéteis
	add_to_group("projectiles")

func _physics_process(delta):
	if is_destroyed:
		return
	
	# Rotaciona o projétil na direção do movimento
	if linear_velocity.length() > 10:
		rotation = linear_velocity.angle()
	
	# Verifica se a velocidade está muito baixa (projétil parado)
	if linear_velocity.length() < 10 and current_bounces > 0:
		destroy_projectile()

# Método chamado pelo inimigo para definir a direção inicial
func set_direction(direction_vector: Vector2):
	linear_velocity = direction_vector
	
	# Pequeno impulso inicial para garantir movimento
	apply_central_impulse(direction_vector * 0.1)

# Método alternativo para definir velocidade
func set_velocity(velocity_vector: Vector2):
	linear_velocity = velocity_vector

# Método para aplicar força ao projétil
func set_force(force_vector: Vector2):
	apply_central_impulse(force_vector)

# Quando o RigidBody2D colide com qualquer corpo
func _on_body_entered(body):
	if is_destroyed:
		return
	
	# Se colidiu com o player - suma imediatamente
	if body.is_in_group("Player"):
		hit_player(body)
		return
	
	# Se colidiu com outras coisas (chão, paredes) - quica
	handle_bounce()

# Função chamada quando detecta colisão com player via área (não usada mais)
func _on_area_body_entered(body):
	# Esta função não é mais necessária
	pass

func hit_player(player):
	if has_hit_player or is_destroyed:
		return
	
	has_hit_player = true
	is_destroyed = true
	
	# Para qualquer movimento
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	
	# Desabilita colisões para evitar mais interações
	collision_layer = 0
	collision_mask = 0
	
	# Verifica se deve matar o player ou apenas causar dano
	if kills_player:
		# Mata o player instantaneamente
		kill_player(player)
	else:
		# Causa dano normal
		if player.has_method("take_damage"):
			player.take_damage(damage)
	
	# Remove o projétil imediatamente
	queue_free()

func kill_player(player):
	# Chama a função de morte do player se existir
	if player.has_method("die"):
		player.die()
	else:
		# Se o player não tem função die, chama nossa própria função
		call_death_screen()

func call_death_screen():
	# Verifica se temos a cena de morte configurada
	if not DIE_SCREEN:
		print("Erro: Cena de morte não configurada no projétil!")
		get_tree().reload_current_scene()
		return
	
	# Instancia a tela de morte
	var ds = DIE_SCREEN.instantiate()
	
	# Adiciona à cena principal (não como filho do projétil que vai ser destruído)
	get_tree().current_scene.add_child(ds)
	
	# Aguarda 10 segundos e recarrega a cena
	await get_tree().create_timer(9.0).timeout
	get_tree().reload_current_scene()

func handle_bounce():
	current_bounces += 1
	
	# Efeito sonoro/visual de quique (opcional)
	create_bounce_effect()
	
	# Se excedeu o número de quiques, destroi
	if current_bounces >= bounce_count:
		destroy_projectile()
	else:
		# Reduz um pouco a velocidade a cada quique
		linear_velocity *= 0.8

func create_impact_effect():
	# Efeito visual simples de impacto
	modulate = Color.YELLOW
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)

func create_bounce_effect():
	# Efeito visual simples de quique
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	tween.tween_property(self, "modulate", Color.GRAY, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func _on_lifetime_timeout():
	# Destroi o projétil após o tempo limite
	destroy_projectile()

func destroy_projectile():
	if is_destroyed:
		return
	
	is_destroyed = true
	
	# Para o movimento
	linear_velocity = Vector2.ZERO
	
	# Desabilita colisões
	collision_layer = 0
	collision_mask = 0
	
	# Efeito visual de destruição
	var tween = create_tween()
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)

# Método para ser chamado externamente se necessário
func explode():
	create_impact_effect()
	destroy_projectile()

# Método para configurar propriedades específicas do projétil
func setup_projectile(proj_damage: int, proj_lifetime: float, proj_bounces: int):
	damage = proj_damage
	lifetime = proj_lifetime
	bounce_count = proj_bounces
	
	if lifetime_timer:
		lifetime_timer.wait_time = lifetime
