extends Node2D
class_name Floresta

const DIE_SCREEN: PackedScene = preload("res://scenes/transicao/die_screen.tscn")
@onready var corvo: AudioStreamPlayer2D = $Corvo
@onready var floresta: AudioStreamPlayer2D = $Floresta

func _ready() -> void:
	_corvo_loop()
	Music.set_music("res://assets/OST/City/RPG City Theme.wav", "res://assets/OST/City/RPG City Pause Theme.wav")
	Global.foi_pra_floresta = true
	if !Music.tocando:
		Music.play()

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
		
func _on_troca_cena_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		Global.current_scene_path = "res://scenes/levels/Caverna/caverna.tscn"
		Global.spawn_pos_escudeiro = Vector2(1500, 160)
		transition_screen.fade_in()
