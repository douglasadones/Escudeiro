extends CharacterBody2D

#-----------------------------------------------------------------------------
# CÓDIGO ATUALIZADO: O morcego começa do ponto onde foi colocado no editor.
#-----------------------------------------------------------------------------

@export_category("Configurações da Patrulha")

@export var velocidade: float = 75.0      # Velocidade do morcego
@export var ponto_a: float = 0.0          # Coordenada X do início da patrulha
@export var ponto_b: float = 3500.0       # Coordenada X do fim da patrulha

# Variável interna que controla a direção
var direcao: int = 1 # 1 para direita, -1 para esquerda

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Esta função é executada uma vez quando o nó entra na cena.
func _ready() -> void:
	# A linha que teleportava o morcego foi REMOVIDA.
	# Agora ele usa a posição definida no editor.
	
	# Apenas garantimos que ele comece virado para o lado certo.
	sprite.flip_h = (direcao < 0)


# A função de física continua a mesma.
func _physics_process(delta: float) -> void:
	# 1. VERIFICAR SE CHEGOU AO DESTINO PARA VIRAR
	if direcao > 0 and global_position.x >= ponto_b:
		direcao = -1
	elif direcao < 0 and global_position.x <= ponto_a:
		direcao = 1

	# 2. ATUALIZAR A APARÊNCIA
	sprite.flip_h = (direcao > 0)
	
	# 3. APLICAR O MOVIMENTO
	velocity.x = direcao * velocidade
	move_and_slide()
