extends Node2D
class_name AreaInicial

const DIALOG_SYSTEM: PackedScene = preload("res://scenes/ui/dialog_box.tscn")
const ESCUDEIRO: PackedScene = preload("res://scenes/player/escudeiro.tscn")

var dialog_index: int = 0

@onready var escudeiro: AnimatedSprite2D = $Escudeiro
@onready var viburno: AnimatedSprite2D = $Viburno
@onready var sikiana: AnimatedSprite2D = $Sikiana

var dialogo_inicial: Dictionary = {
	0: {
		"title": "Escudeiro",
		"dialog": "Ahhhhh!",
	},
	1: {
		"title": "Sikiana",
		"dialog": "Cale-se! Isso é remédio! Nossa Senhora ordenou que o cuidássemos! Não atrapalhe nosso dever.",
	},
	2: {
		"title": "Viburno",
		"dialog": "[expira com força, em concordância com Sikiana]",
	},
	3: {
		"title": "Escudeiro",
		"dialog": "Onde está minha Senhora… Sou seu Escudeiro… Eu devo…",
	},
	4: {
		"title": "Sikiana",
		"dialog": "No último momento, ela mudou de ideia. Antes que a corda a matasse…",
	},
	5: {
		"title": "Sikiana",
		"dialog": "Ela pensou melhor. Sorte sua, não?",
	},
	6: {
		"title": "Sikiana",
		"dialog": "Ela mudou de ideia… bem antes que você morresse.",
	},
	7: {
		"title": "",
		"dialog": "(Há um esboço de sorriso zombeteiro no rosto de Sikiana, mas é um átimo. Sua face logo perde a expressão.)",
	},
	8: {
		"title": "Sikiana",
		"dialog": "Está indo recuperar sua honra. Bem… vai tentar.",
	},
	9: {
		"title": "Viburno",
		"dialog": "[expira com força, novamente em silêncio e aprovação]",
	},
	10: {
		"title": "Escudeiro",
		"dialog": "Recuperando o fôlego:\nNão, ela não irá traí-lo! Como?",
	},
	11: {
		"title": "Sikiana",
		"dialog": "Traição ou traição.",
	},
	12: {
		"title": "Sikiana",
		"dialog": "É o preço da sua tolice. Deixe ser o que tem que ser. Seja um bom garoto, fique quieto e deixe-me terminar o meu trabalho.",
	},
	13: {
		"title": "Viburno",
		"dialog": "[expira com força, em definitivo]",
	},
}

var novo_escudeiro

func _ready() -> void:
	spawn_dialog(dialogo_inicial)

func spawn_dialog(dialog_info: Dictionary) -> void:
	var dialog_box: DialogBox = DIALOG_SYSTEM.instantiate()
	dialog_box.name = "DialogBox"
	dialog_box.dialog_data = dialog_info
	dialog_box.connect("dialog_finished", Callable(self, "_on_dialog_finished"))
	add_child(dialog_box)

func _on_dialog_finished() -> void:
	# Dispara a transição (assumindo que 'transition_screen' está definido e tem fade_in)
	transition_screen.fade()

	# Espera 5 segundos (pode ajustar esse tempo pra duração da animação)
	await get_tree().create_timer(2).timeout

	# Faz o que precisa com os personagens (certifique-se que as variáveis existem)
	if escudeiro:
		escudeiro.queue_free()
	if sikiana:
		sikiana.queue_free()
	if viburno:
		viburno.queue_free()
		
	novo_escudeiro = ESCUDEIRO.instantiate()
	add_child(novo_escudeiro)
	novo_escudeiro.position = Vector2(209, 200)
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == novo_escudeiro:
		Global.current_scene_path = "res://scenes/levels/Caverna/caverna.tscn"
		transition_screen.cap02()
