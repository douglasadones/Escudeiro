# Nome do script pode ser ChoiceBox.gd ou Choise.gd
extends CanvasLayer
class_name ChoiceBox

signal choice_made(was_yes: bool)

# Referências aos nós da cena.
@onready var yes_button: Button = $HBoxContainer/Sim
@onready var no_button: Button = $HBoxContainer/Nao
#@onready var question_label: Label = $VBoxContainer/Label

var player_node: Node2D

func _ready() -> void:
	yes_button.pressed.connect(_on_yes_pressed)
	no_button.pressed.connect(_on_no_pressed)

# Esta é a função que o script da Adega chama.
func prompt(question: String, p_node: Node2D) -> void:
	player_node = p_node
	
	# --- CORREÇÃO AQUI ---
	# A linha abaixo foi descomentada para que o texto seja aplicado ao Label.
	#question_label.text = question
	
	visible = true # Torna a caixa de escolha visível
	
	if player_node and player_node.has_method("set_physics_process"):
		player_node.set_physics_process(false)
	
	yes_button.grab_focus()

func _on_yes_pressed() -> void:
	_handle_choice(true)

func _on_no_pressed() -> void:
	_handle_choice(false)

func _handle_choice(was_yes: bool) -> void:
	print("O jogador selecionou: " + ("SIM" if was_yes else "NÃO"))
	emit_signal("choice_made", was_yes)
	
	if player_node and player_node.has_method("set_physics_process"):
		player_node.set_physics_process(true)

	queue_free()
