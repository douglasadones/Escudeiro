extends CharacterBody2D
class_name Player

@onready var sprite: AnimatedSprite2D = get_node("Texture")
@export var speed: int = 300
@export var jump_force: int = -400.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		sprite.scale.x = direction
		velocity.x = direction * speed
		sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		sprite.play("idle")

	move_and_slide()
