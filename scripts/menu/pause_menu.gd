extends CanvasLayer
class_name PauseMenu

@onready var resume: Button = $ButtonsContainer/Resume

var pausado: bool = false
var pause_enabled: bool = true  # controla se o menu pode pausar ou não

func _ready() -> void:
	visible = false
	pause_enabled = true
	set_process_input(true)
	set_process(true)

func _unhandled_input(event: InputEvent) -> void:
	if not pause_enabled:
		return  # ignora o pause quando desativado

	if event.is_action_pressed("ui_cancel"):
		if visible:
			# Fechar menu de pausa
			get_tree().paused = false
			pausado = false
			visible = false
			Music.resume()
		else:
			# Abrir menu de pausa
			visible = true
			get_tree().paused = true
			pausado = true
			resume.grab_focus()
			Music.pausa()

func disable_pause_menu() -> void:
	pause_enabled = false
	visible = false
	pausado = false
	get_tree().paused = false
	set_process_input(false)
	set_process(false)

func enable_pause_menu() -> void:
	pause_enabled = true
	set_process_input(true)
	set_process(true)

func _on_new_game_pressed() -> void:
	get_tree().paused = false
	pausado = false
	visible = false
	Music.resume()

func _on_exit_pressed() -> void:
	get_tree().paused = false
	pausado = false
	Music.stop()
	Global.current_scene_path = "res://scenes/menu/main_menu.tscn"
	transition_screen.fade_in()

func _on_fade_finished() -> void:
	get_tree().change_scene_to_file(Global.current_scene_path)
