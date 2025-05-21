extends Node

var playerBody: CharacterBody2D
var playerWeaponEquip: bool
var playerDamageZone: Area2D
var playerDamageAmount: int

var current_scene_path: String

var primeira_vez_caverna: bool = true
var spawn_pos_escudeiro: Vector2 = Vector2(100, 160)

var foi_pra_floresta: bool = false

func spawn_effect(_path: String, offset: Vector2, initial_position: Vector2, is_flipped: bool) -> void:
	var effect: BaseEffect = load(_path).instantiate()
	effect.global_position = initial_position + offset
	effect.flip_h = is_flipped
	
	get_tree().root.call_deferred("add_child", effect)
