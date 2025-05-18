extends CanvasLayer
class_name TransitionScreen

var scene_path: String

@onready var animation: AnimationPlayer = $Animation

func fade_in() -> void:
	scene_path = Global.current_scene_path
	animation.play("fade_in")

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
		
