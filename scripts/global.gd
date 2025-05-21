extends Node

var playerBody: CharacterBody2D
var playerWeaponEquip: bool
var playerDamageZone: Area2D
var playerDamageAmount: int

var current_scene_path: String

var primeira_vez_caverna: bool = true
var spawn_pos_escudeiro: Vector2 = Vector2(100, 160)

var foi_pra_floresta: bool = false
