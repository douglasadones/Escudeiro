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

var walk_step_sound := preload("res://assets/audio/Sound Effects/Primeira Fase/passos/walk_step.wav")
var walk_effect_path := "res://scenes/effects/walk_effect.tscn"


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

		else:
			is_running = true
			velocity.x = direction * SPEED*1.2
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if audio_effect.playing:
			audio_effect.stop()
			
	


func _on_texture_frame_changed() -> void:
	match texture.animation:
		"run":
			if texture.frame == 2 or texture.frame == 6:
				spawn_walk_effect()
				play_step_sound(1.5)
		"walk":
			if texture.frame in [3, 8]:
				play_step_sound(1.0)

func spawn_walk_effect():
	var offset: Vector2
	if texture.flip_h:
		offset = Vector2(30, 2)
	else:
		offset = Vector2(-30, 2)

	Global.spawn_effect(walk_effect_path, offset, global_position, !texture.flip_h)

func play_step_sound(pitch: float):
	audio_effect.stream = walk_step_sound
	audio_effect.pitch_scale = pitch
	audio_effect.stop()
	audio_effect.play()
