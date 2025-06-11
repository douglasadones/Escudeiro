extends CanvasLayer

@onready var audio: AudioStreamPlayer2D = $Audio

func _ready() -> void:
	Music.stop()
	Pausa.disable_pause_menu()
