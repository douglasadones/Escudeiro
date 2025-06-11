extends Node2D

##-- ADIÇÃO: Variável para controlar se a interação é possível --##
var pode_interagir: bool = false

func _ready() -> void:
	Music.set_music("res://assets/OST/End Song/RPG End Song.wav", "res://assets/OST/End Song/RPG End Song.wav")
	Music.play()

##-- ADIÇÃO: Função _process para verificar o input a cada frame --##
func _process(delta: float) -> void:
	# Se o jogador pode interagir e aperta o botão
	if pode_interagir and Input.is_action_just_pressed("interagir"):
		# Desativa a interação para evitar múltiplos cliques durante a transição
		pode_interagir = false
		print("Iniciando transição final!")
		transition_screen.fim()

# Esta função agora SÓ avisa que o jogador PODE interagir
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir = true

##-- ADIÇÃO: Função para quando o jogador SAI da área --##
# É importante para desativar a interação se ele sair.
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Escudeiro":
		pode_interagir = false
