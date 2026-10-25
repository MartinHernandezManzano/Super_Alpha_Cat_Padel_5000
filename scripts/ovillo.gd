extends CharacterBody2D

# velocidad en pixeles por segundo, se puede cambiar desde el inspector
@export var velocidad: float = 300.0

func _ready() -> void:
	# direccion inicial en diagonal, normalized la deja con longitud 1
	velocity = Vector2(1, 0.6).normalized() * velocidad

func _physics_process(delta: float) -> void:
	# mueve el ovillo y si choca con algo devuelve info del choque
	var choque := move_and_collide(velocity * delta)
	if choque:
		# rebota usando la normal de la superficie con la que choco
		velocity = velocity.bounce(choque.get_normal())
