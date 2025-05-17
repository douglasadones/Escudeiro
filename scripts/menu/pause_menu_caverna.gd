extends CanvasLayer
class_name PauseMenuCaverna

@onready var resume: Button = $ButtonsContainer/Resume

@onready var musica: AudioStreamPlayer2D = $"../Musica"
@onready var musica_pausado: AudioStreamPlayer2D = $"../MusicaPausado"


var pausado: bool = false

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			get_tree().paused = false
			pausado = false
			visible = false
			musica.volume_db = 0
			musica_pausado.volume_db = -80

		else:
			# Abre o menu de pausa
			visible = true
			get_tree().paused = true
			pausado = true
			resume.grab_focus()
			
			musica.volume_db = -100
			musica_pausado.volume_db = 0

func _on_new_game_pressed() -> void:
	get_tree().paused = false
	pausado = false
	visible = false
	musica.volume_db = 0
	musica_pausado.volume_db = -100

func _on_exit_pressed() -> void:
	get_tree().paused = false
	pausado = false
	Global.current_scene_path = "res://scenes/menu/main_menu.tscn"
	transition_screen.fade_in()

func _on_fade_finished() -> void:
	get_tree().change_scene_to_file(Global.current_scene_path)
