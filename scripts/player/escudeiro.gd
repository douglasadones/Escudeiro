extends CharacterBody2D

const SPEED = 720.0
const JUMP_VELOCITY = -820.0
var max_health = 100
var min_health = 0
var health = 100
var dead: bool
var is_idle: bool
var is_crouch: bool
var attack_type: String
var current_attack: bool
var is_running: bool
var is_rolling: bool
@onready var animated_knight: AnimatedSprite2D = $AnimatedSprite2D
#@onready var attack_area: Area2D = $Area2D


func _ready():
	current_attack = false
	#attack_area.get_node("attack_area").disabled = true
	is_running = false
	is_rolling = false
	#Global.playerDamageZone = attack_area

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("pular") and is_on_floor() and !is_rolling:
		velocity.y = JUMP_VELOCITY
	
		
	var direction := Input.get_axis("a", "d")
	
	if direction:
		
		if Input.is_action_pressed("agachar"):
			velocity.x = direction * SPEED/4
			
		if !Input.is_action_pressed("correr") and !is_crouch:
			velocity.x = direction * SPEED/2
			
			
		if Input.is_action_pressed("correr") and !is_crouch:
			velocity.x = direction * SPEED
		
		if is_rolling:
			velocity.x = direction * SPEED*1.3
			
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if !is_rolling:
		if is_running and Input.is_action_just_pressed("agachar"):
			
			is_rolling = true
			if is_on_floor():
				handle_rolling_animation()
			
			
		
		
	if !current_attack:
		if Input.is_action_just_pressed("click_esquerdo") or Input.is_action_just_pressed("click_direito"):
			current_attack = true
			if Input.is_action_just_pressed("click_esquerdo") and is_on_floor():
				attack_type = "attack1NoMove"
			if Input.is_action_just_pressed("click_direito") and is_on_floor():
				attack_type = "attack2NoMove"
			if Input.is_action_just_pressed("click_esquerdo") and is_on_floor() and Input.is_action_pressed("agachar"):
				attack_type = "crouch_attack"
			
			set_damage(attack_type)
			handle_attack_animation(attack_type)
			
	if !current_attack:
		move_and_slide()
		if !is_rolling:
			handle_moviment_animation(direction)


func handle_moviment_animation(dir):
	
	if is_on_floor() and !current_attack and !Input.is_action_pressed("agachar"):
		
		if !velocity:
			animated_knight.play("idle")
			is_idle = true
			is_crouch = false
			is_running = false
			$Camera2D.zoom = Vector2(0.2,0.2)
			
			
		if velocity:
			$Camera2D.zoom = Vector2(0.2,0.2)
			is_idle = false
			is_crouch = false
			toogle_flip_sprite(dir)
			if velocity.x == dir * SPEED:
				animated_knight.play("run")
				is_running = true
			else:
				animated_knight.play("walk")
				is_running = false
			
	elif is_on_floor() and !current_attack and Input.is_action_pressed("agachar") and !is_running:
		
		if !velocity:
			$Camera2D.zoom = Vector2(1,1)
			animated_knight.play("crouch")
			is_idle = true
			is_crouch = true
			is_running = false
			
		if velocity:
			$Camera2D.zoom = Vector2(1,1)
			animated_knight.play("crouch_walk")
			is_idle = false
			is_crouch = true
			is_running = false
			toogle_flip_sprite(dir)
			
	if !is_on_floor():
		is_idle = false
		is_crouch = false
		is_running = false
		is_rolling = false
		animated_knight.play("jump")
		if dir:
			toogle_flip_sprite(dir)
	

func toogle_flip_sprite(dir):
	if dir == 1:
		animated_knight.flip_h = false
		#attack_area.scale.x = 1
	if dir == -1:
		animated_knight.flip_h = true
		#attack_area.scale.x = -1
		
func set_damage(attack_type):
	var current_damage_to_deal: int
	if attack_type == "attack1NoMove":
		current_damage_to_deal = 10
	if attack_type == "attack2NoMove":
		current_damage_to_deal = 20
	if attack_type == "crouch_attack":
		current_damage_to_deal = 5
	Global.playerDamageAmount = current_damage_to_deal
	
	

func handle_attack_animation(attack):
	#print(attack)
	if current_attack:
		animated_knight.play(attack)
		toggle_damage_collision(attack)

func handle_rolling_animation():
	if is_rolling:
		animated_knight.play("roll")
		await get_tree().create_timer(0.6).timeout
		Input.action_release("agachar")
		is_rolling = false
		
		
		
func toggle_damage_collision(attack_type):
	#var damage_zone_collision = attack_area.get_node("attack_area")
	var wait_time: float
	if attack_type == "attack1NoMove":
		wait_time = 0.33
	if attack_type == "attack2NoMove":
		wait_time = 1
	if attack_type == "crouch_attack":
		wait_time = 0.5
	#damage_zone_collision.disabled = false
	await get_tree().create_timer(wait_time).timeout
	#damage_zone_collision.disabled = true
	current_attack = false
	


func _on_animated_sprite_2d_animation_finished() -> void:
	#current_attack = false
	#is_rolling = false
	pass
