extends Node2D

const DIE_SCREEN: PackedScene = preload("res://scenes/transicao/die_screen.tscn")

func die() -> void :
	var ds = DIE_SCREEN.instantiate()
	add_child(ds)
	await get_tree().create_timer(10.0).timeout
	get_tree().reload_current_scene()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		die()
		
