extends CharacterBody2D

# Define a velocidade de movimento do rato.
# Você pode ajustar este valor conforme necessário.
const SPEED = 150.0

func _physics_process(delta):
	# Define a velocidade no eixo x para ser negativa,
	# o que causa o movimento para a esquerda.
	velocity.x = -SPEED

	# A função move_and_slide() aplica a velocidade ao personagem,
	# fazendo-o se mover e colidir com o ambiente.
	move_and_slide()
