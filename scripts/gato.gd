extends CharacterBody2D

# velocidad del gato en pixeles por segundo
@export var velocidad: float = 250.0

# señal propia: avisa de que el jugador quiere interactuar
signal interact_requested

func _physics_process(_delta: float) -> void:
	# lee las 4 teclas y devuelve la direccion como vector (x, y)
	var direccion := Input.get_vector("p1_izquierda", "p1_derecha", "p1_arriba", "p1_abajo")
	velocity = direccion * velocidad
	# mueve el gato y si choca con algo se para o se desliza
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	# si se pulsa la tecla de interact, emite la señal
	if event.is_action_pressed("interact"):
		interact_requested.emit()
