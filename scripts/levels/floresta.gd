extends Node2D
class_name Floresta

const DIE_SCREEN: PackedScene = preload("res://scenes/transicao/die_screen.tscn")
@onready var corvo: AudioStreamPlayer2D = $Corvo
@onready var floresta: AudioStreamPlayer2D = $Floresta

func _ready() -> void:
	_corvo_loop()

func _on_npc_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		die()

func die() -> void:
	var ds = DIE_SCREEN.instantiate()
	add_child(ds)
	await get_tree().create_timer(8.0).timeout
	get_tree().reload_current_scene()

func _on_floresta_finished() -> void:
	floresta.play()

func _corvo_loop() -> void:
	while true:
		await get_tree().create_timer(8.0).timeout
		corvo.play()
