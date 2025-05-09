extends CharacterBody2D
class_name Escudeiro

@export_category("Variables")
@export var SPEED: float = 220.0
@export var JUMP_VELOCITY: float = -510.0

#Status
var max_health = 100
var min_health = 0
var health = 100
var dead: bool
var is_idle: bool
var is_crouch: bool
var attack_type: String
var _on_floor: bool = true

@onready var current_attack: bool = false
@onready var is_running: bool = false
@onready var is_rolling: bool = false
@onready var texture: AnimatedSprite2D = $Texture


func _physics_process(delta: float) -> void:
	vertical_move(delta)
	horizontal_move()
	move_and_slide()
	texture.animate(velocity)

func vertical_move(delta: float):
	if is_on_floor():
		if _on_floor == false:
			texture.action_animation("land")
			texture.position.y = -18
			set_physics_process(false)
			_on_floor = true
	
	if not is_on_floor():
		$Camera2D.drag_vertical_enabled = true
		$Camera2D.drag_top_margin = 0.4
		$Camera2D.drag_bottom_margin = 0.4
		_on_floor = false
		velocity += (get_gravity() * 1.5 ) * delta

	if Input.is_action_just_pressed("pular") and is_on_floor() and !is_rolling:
		velocity.y = JUMP_VELOCITY

func horizontal_move():
	var direction := Input.get_axis("a", "d")
	
	if direction:
		if !Input.is_action_pressed("correr"):
			velocity.x = direction * SPEED/2
			
		if Input.is_action_pressed("correr"):
			velocity.x = direction * SPEED

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
#
