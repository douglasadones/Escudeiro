extends CanvasLayer
class_name TransitionScreen

var scene_path: String

@onready var animation: AnimationPlayer = $Animation

func fade_in() -> void:
	scene_path = Global.current_scene_path
	animation.play("fade_in")
	
func cap01() -> void:
	scene_path = Global.current_scene_path
	animation.play("cap01")

func cap02() -> void:
	scene_path = Global.current_scene_path
	animation.play("cap02")

func fade() -> void:
	animation.play("fade_in2")

func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"fade_in":
			get_tree().change_scene_to_file(scene_path)
			animation.play("fade_out")
		"fade_out":
			pass
		"fade":
			get_tree().change_scene_to_file(scene_path)
			animation.play("fade")
		"cap01":
			get_tree().change_scene_to_file(scene_path)
			animation.play("fade_out")
			Music.stop()
		"cap02":
			get_tree().change_scene_to_file(scene_path)
			animation.play("fade_out")
			Music.stop()
		"fade_in2":
			animation.play("fade_out")

		
