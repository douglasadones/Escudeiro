extends Node2D

const DIALOG_SYSTEM: PackedScene = preload("res://scenes/ui/dialog_box.tscn")
@onready var escudeiro: Escudeiro = $"../Escudeiro"

var dialogo_1: Dictionary = {
	0: {
		"title": "​",
		"dialog": "Pressione △ para interagir.",
	},
}

var dialogo_2: Dictionary = {
	0: {
		"title": "​",
		"dialog": "Pressione R1 para correr.",
	},
}

var dialogo_3: Dictionary = {
	0: {
		"title": "​",
		"dialog": "Pressione x para pular.",
	},
}



func spawn_dialog(dialog_info: Dictionary) -> void:
	var ds = DIALOG_SYSTEM.instantiate()
	ds.dialog_data = dialog_info
	add_child(ds)


func _on_p_1_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		spawn_dialog(dialogo_1)
		escudeiro.texture.play("idle")
		$P1.queue_free()

func _on_p_2_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		spawn_dialog(dialogo_2)
		escudeiro.texture.play("idle")
		$P2.queue_free()

func _on_p_3_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		spawn_dialog(dialogo_3)
		escudeiro.texture.play("idle")
		$P3.queue_free()
