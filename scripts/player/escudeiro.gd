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
var is_dead: bool = false
var is_idle: bool
var is_crouch: bool
var attack_type: String
var _on_floor: bool = true
var frame_counter := 0
signal player_died
@onready var current_attack: bool = false
@onready var is_running: bool = false
@onready var is_rolling: bool = false
@onready var texture: AnimatedSprite2D = $Texture
var pode_ir: bool = false

var walk_step_sound := preload("res://assets/audio/Sound Effects/Primeira Fase/passos/walk_step.wav")
var walk_effect_path := "res://scenes/effects/walk_effect.tscn"
signal hold_started
signal hold_progress_updated(progress: float)
signal hold_completed
signal hold_cancelled

@onready var hold_timer = Timer.new()
@onready var audio_player = AudioStreamPlayer2D.new()

var is_holding_e = false
var hold_duration = 0.6
var initial_position: Vector2
var max_movement_distance = 50.0

func _ready() -> void:
	add_to_group("Player")
	_setup_timer()
	_setup_audio()
	
func _setup_timer():
	add_child(hold_timer)
	hold_timer.wait_time = hold_duration
	hold_timer.one_shot = true
	hold_timer.timeout.connect(_on_hold_complete)

func _setup_audio():
	add_child(audio_player)
	# audio_player.stream = preload("res://sounds/hold_sound.ogg")

func _input(event):
	if event.is_action_pressed("interagir"):
		_start_holding()
	
	if event.is_action_released("interagir"):
		_stop_holding()

func _start_holding():
	if not is_holding_e:
		is_holding_e = true
		initial_position = global_position
		hold_timer.start()
		
		hold_started.emit()
		
		if audio_player.stream:
			audio_player.play()

func _stop_holding():
	if is_holding_e and hold_timer.time_left > 0:
		_cancel_hold()

func _cancel_hold():
	if is_holding_e:
		is_holding_e = false
		hold_timer.stop()
		hold_cancelled.emit()

func _on_hold_complete():
	if is_holding_e:
		is_holding_e = false
		hold_completed.emit()

func _physics_process(delta: float) -> void:
	vertical_move(delta)
	horizontal_move()
	texture.animate(velocity)
	move_and_slide()
	
	if is_holding_e:
		var progress = 1.0 - (hold_timer.time_left / hold_duration)
		hold_progress_updated.emit(progress)
		
		# Verificar movimento
		if global_position.distance_to(initial_position) > max_movement_distance:
			_cancel_hold()

func vertical_move(delta: float):
	
	if not is_on_floor():
		_on_floor = false
		velocity += (get_gravity() * 1.5 ) * delta

	if Input.is_action_just_pressed("pular") and is_on_floor() and !is_rolling and !Input.is_action_pressed("interagir"):
		velocity.y = JUMP_VELOCITY

func horizontal_move():
	var direction := Input.get_axis("a", "d")
	
	if direction and !Input.is_action_pressed("interagir"):
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
		offset = Vector2(30, 17)
	else:
		offset = Vector2(-30, 17)

	Global.spawn_effect(walk_effect_path, offset, global_position, !texture.flip_h)

func play_step_sound(pitch: float):
	audio_effect.stream = walk_step_sound
	audio_effect.pitch_scale = pitch
	audio_effect.stop()
	audio_effect.play()

func die():
	is_dead = true
	player_died.emit()
