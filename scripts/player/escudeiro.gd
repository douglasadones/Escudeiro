extends CharacterBody2D
class_name Escudeiro

@export_category("Variables")
@export var SPEED: float = 220.0
@export var JUMP_VELOCITY: float = -510.0

@onready var audio_effect: AudioStreamPlayer2D = $AudioEffect


#Status
var max_health = 100
var min_health = 0
var health = 100
var dead: bool
var is_idle: bool
var is_crouch: bool
var attack_type: String
var _on_floor: bool = true
var frame_counter := 0

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
	
	if not is_on_floor():
		_on_floor = false
		velocity += (get_gravity() * 1.5 ) * delta

	if Input.is_action_just_pressed("pular") and is_on_floor() and !is_rolling:
		velocity.y = JUMP_VELOCITY

func horizontal_move():
	var direction := Input.get_axis("a", "d")
	
	if direction:
		if !Input.is_action_pressed("correr"):
			is_running = false
			velocity.x = direction * SPEED / 2
			if audio_effect.stream != preload("res://assets/audio/Sound Effects/Primeira Fase/passos/walk_step.wav"):
				audio_effect.stream = preload("res://assets/audio/Sound Effects/Primeira Fase/passos/walk_step.wav")
			if !audio_effect.playing:
				audio_effect.pitch_scale = 1.0
				audio_effect.play()
		else:
			is_running = true
			velocity.x = direction * SPEED*1.2
			if audio_effect.stream != preload("res://assets/audio/Sound Effects/Primeira Fase/passos/walk_step.wav"):
				audio_effect.stream = preload("res://assets/audio/Sound Effects/Primeira Fase/passos/walk_step.wav")
			if !audio_effect.playing:
				audio_effect.pitch_scale = 1.2
				audio_effect.play()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if audio_effect.playing:
			audio_effect.stop()
