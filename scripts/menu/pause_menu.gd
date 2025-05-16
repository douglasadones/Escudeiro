extends CanvasLayer
class_name PauseMenu

@onready var resume: Button = $ButtonsContainer/Resume
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			get_tree().paused = false
			visible = false
			audio_stream_player_2d.stop()
		else:
			# Abre o menu de pausa
			visible = true
			get_tree().paused = true
			resume.grab_focus()
			audio_stream_player_2d.play()

func _on_new_game_pressed() -> void:
	get_tree().paused = false
	visible = false
	audio_stream_player_2d.stop()

func _on_exit_pressed() -> void:
	get_tree().paused = false
	Global.current_scene_path = "res://scenes/menu/main_menu.tscn"
	transition_screen.fade_in()

func _on_fade_finished() -> void:
	get_tree().change_scene_to_file(Global.current_scene_path)
