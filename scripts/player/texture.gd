extends AnimatedSprite2D
class_name EscudeiroTexture

var _is_on_action: bool = false

@export_category("Objects")
@export var _character: Escudeiro

func animate(_velocity: Vector2):
	_verify_direction(_velocity.x)
	
	if _is_on_action:
		return
	if _character.is_dead:
		_character.is_idle = true
		play("death")
		return
	
	if not _velocity:
		play("idle")
		return
		
	if _velocity.y:
		if sign(_velocity.y) == -1:
			play("jump")
		if sign(_velocity.y) == 0:
			play("fall")
		if sign(_velocity.y) == 1:
			play("land")
		
		return
		
	if _velocity.x:
		if _character.is_running:
			play("run")
		else:
			play("walk")


func _verify_direction(_direction: float) -> void:
	if _direction > 0:
		flip_h = false

	elif _direction < 0:
		flip_h = true


func action_animation(_action_name: String) -> void:
	_is_on_action = true
	play(_action_name)


func _on_animation_finished() -> void:
	_character.set_physics_process(true)
	_is_on_action = false
	position.y = 0
