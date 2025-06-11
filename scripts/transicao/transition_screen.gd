extends CanvasLayer
class_name TransitionScreen

var scene_path: String

@onready var animation: AnimationPlayer = $Animation

var is_skippable := false

func _process(delta: float) -> void:
	if is_skippable and Input.is_action_just_pressed("ui_accept"):
		# MUDANÇA: Agora passamos o nome da animação que está tocando.
		_end_chapter_animation(animation.current_animation)

func fade_in() -> void:
	scene_path = Global.current_scene_path
	is_skippable = false
	animation.play("fade_in")

func cap01() -> void:
	scene_path = Global.current_scene_path
	is_skippable = false
	animation.play("cap01")
	Music.stop()

func cap02() -> void:
	scene_path = Global.current_scene_path
	is_skippable = false
	animation.play("cap02")
	Music.stop()
	
func cap03() -> void:
	scene_path = Global.current_scene_path
	is_skippable = false
	animation.play("cap03")
	Music.stop()

func cap04() -> void:
	scene_path = Global.current_scene_path
	is_skippable = false
	animation.play("cap04")
	Music.stop()

func fim() -> void:
	scene_path = Global.current_scene_path
	is_skippable = false
	animation.play("Fim")

func fade() -> void:
	scene_path = Global.current_scene_path
	is_skippable = false
	animation.play("fade_in2")
	Music.stop()

# MUDANÇA: A função agora aceita o nome da animação como um parâmetro.
func _end_chapter_animation(anim_name: String) -> void:
	# Se a animação já foi pulada ou o nome veio vazio, não faz nada.
	if not is_skippable or anim_name == "":
		return
	
	is_skippable = false
	
	animation.stop()
	
	# Agora usamos o nome que recebemos, que sempre estará correto.
	animation.seek(animation.get_animation(anim_name).length, true)
	
	await get_tree().process_frame
	
	get_tree().change_scene_to_file(scene_path)
	animation.play("fade_out")
	Music.stop()


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
		"cap01", "cap02", "cap03", "cap04":
			get_tree().change_scene_to_file(scene_path)
			animation.play("fade_out")
		"Fim":
			get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
		"fade_in2":
			animation.play("fade_out")
