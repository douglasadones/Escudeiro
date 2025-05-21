extends Node2D
class_name Musica

@onready var musica_pausado: AudioStreamPlayer2D = $MusicaPausado
@onready var musica: AudioStreamPlayer2D = $Musica

var tocando = false

func play() -> void: 
	musica.play()
	musica_pausado.play()
	tocando = true

func stop() -> void:
	resume()
	musica.stop()
	musica_pausado.stop()
	tocando = false

func pausa() -> void: 
	musica.volume_db = -80
	musica_pausado.volume_db = 0
	
func resume() -> void:
	musica.volume_db = 0
	musica_pausado.volume_db = -80

func _on_musica_pausado_finished() -> void:
	musica_pausado.play()
	
func _on_musica_finished() -> void:
	musica.play()
