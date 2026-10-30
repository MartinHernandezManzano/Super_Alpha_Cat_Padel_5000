extends CharacterBody2D

# señal propia: avisa de que el jugador quiere sacar
signal interact_requested(jugador: int)

# numero de jugador: 1 usa teclas p1_..., 2 usa teclas p2_...
@export var jugador: int = 1
# sprite del gato, si se deja vacio usa el que trae la escena
@export var textura: Texture2D
# nombre del gato para los mensajes (miguel, uma, tinsel, mati)
@export var nombre: String = "Miguel"
@export var velocidad: float = 340.0

func _ready() -> void:
	# si le hemos puesto otra textura desde el inspector la cargamos
	if textura:
		$Sprite2D.texture = textura

func _physics_process(_delta: float) -> void:
	# monta el nombre de las acciones segun el jugador, ej: "p2_arriba"
	var p := "p" + str(jugador) + "_"
	var direccion := Input.get_vector(p + "izquierda", p + "derecha", p + "arriba", p + "abajo")
	velocity = direccion * velocidad
	move_and_slide()
	# si al moverse el gato ha chocado con el ovillo, se lo dice al ovillo
	for i in get_slide_collision_count():
		var otro = get_slide_collision(i).get_collider()
		if otro.is_in_group("ovillo"):
			otro.golpear(self)

func _unhandled_input(event: InputEvent) -> void:
	# cada jugador saca con su propia tecla
	if event.is_action_pressed("p" + str(jugador) + "_saque"):
		interact_requested.emit(jugador)
