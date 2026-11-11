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
# dash: acelerón corto en la direccion en la que se mueve
@export var velocidad_dash: float = 900.0
@export var duracion_dash: float = 0.1
var tiempo_dash: float = 0.0          # lo que queda de dash, 0 = no esta en dash
var direccion_dash: Vector2 = Vector2.ZERO
# estamina: el dash gasta, se recupera sola (mas rapido si estas quieto)
@export var estamina_max: float = 100.0
@export var coste_dash: float = 60.0
@export var recuperacion_quieto: float = 40.0    # por segundo
@export var recuperacion_moviendo: float = 12.0  # por segundo
var estamina: float = 100.0
# dormido: si intenta un dash sin estamina se queda frito un rato
@export var duracion_sueno: float = 1.0
var tiempo_sueno: float = 0.0   # lo que le queda de siesta, 0 = despierto
# ultima direccion de cada eje, para saber que tecla se pulso primero
var eje_x: int = 0
var eje_y: int = 0
var textura_dormido: Texture2D

func _ready() -> void:
	# si le hemos puesto otra textura desde el inspector la cargamos
	if textura:
		$Sprite2D.texture = textura
	else:
		# sin textura en el inspector nos quedamos con la de la escena
		textura = $Sprite2D.texture
	$Barra.max_value = estamina_max
	reiniciar()

func _physics_process(delta: float) -> void:
	if tiempo_sueno > 0:
		# dormido: no se mueve, pero sigue ahi y el ovillo puede rebotar en el
		tiempo_sueno -= delta
		velocity = Vector2.ZERO
		if tiempo_sueno <= 0:
			despertar()
		return
	if tiempo_dash > 0:
		# durante el dash va recto y rapido, ignora las teclas
		tiempo_dash -= delta
		velocity = direccion_dash * velocidad_dash
	else:
		var direccion := leer_direccion()
		velocity = direccion * velocidad
		# recupera estamina, poco si se mueve y mucho si esta quieto
		var recupera: float = recuperacion_moviendo
		if direccion == Vector2.ZERO:
			recupera = recuperacion_quieto
		estamina = min(estamina + recupera * delta, estamina_max)
	actualizar_barra()
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

func poner_gato(nueva_textura: Texture2D, nuevo_nombre: String, nueva_textura_dormido: Texture2D) -> void:
	# cambia el aspecto, el nombre y la cara de dormido del gato
	textura = nueva_textura
	nombre = nuevo_nombre
	textura_dormido = nueva_textura_dormido
	$Sprite2D.texture = nueva_textura

func leer_direccion() -> Vector2:
	# monta el nombre de las acciones segun el jugador, ej: "p2_arriba"
	var p := "p" + str(jugador) + "_"
	# cada eje por separado para que mande la primera tecla pulsada
	eje_x = leer_eje(eje_x, p + "izquierda", p + "derecha")
	eje_y = leer_eje(eje_y, p + "arriba", p + "abajo")
	# normalized para que en diagonal no vaya mas rapido
	return Vector2(eje_x, eje_y).normalized()

func leer_eje(actual: int, tecla_menos: String, tecla_mas: String) -> int:
	# devuelve -1, 0 o 1 para un eje (izquierda/derecha o arriba/abajo)
	var menos := Input.is_action_pressed(tecla_menos)
	var mas := Input.is_action_pressed(tecla_mas)
	if menos and mas:
		# las dos a la vez: sigue la que ya estaba pulsada antes
		if actual != 0:
			return actual
		return -1  # pulsadas en el mismo instante, gana cualquiera
	if menos:
		return -1
	if mas:
		return 1
	return 0

func dash() -> bool:
	# devuelve true si ha hecho el dash, false si no (quieto, ya en dash o dormido)
	if tiempo_sueno > 0:
		return false
	var direccion := leer_direccion()
	if direccion == Vector2.ZERO or tiempo_dash > 0:
		return false
	# sin estamina suficiente no hay dash: se queda dormido
	if estamina < coste_dash:
		dormir()
		return false
	estamina -= coste_dash
	direccion_dash = direccion.normalized()
	tiempo_dash = duracion_dash
	return true

func reiniciar() -> void:
	# despierto, estamina llena y sin dash, se llama al empezar cada punto
	tiempo_dash = 0.0
	despertar()

func dormir() -> void:
	tiempo_sueno = duracion_sueno
	tiempo_dash = 0.0
	estamina = 0.0
	if textura_dormido:
		$Sprite2D.texture = textura_dormido
	actualizar_barra()
	print("jugador ", jugador, " se ha dormido")

func despertar() -> void:
	# vuelve su cara normal y se levanta descansado
	tiempo_sueno = 0.0
	estamina = estamina_max
	$Sprite2D.texture = textura
	actualizar_barra()

func actualizar_barra() -> void:
	$Barra.value = estamina
	# solo se ve si no esta llena
	$Barra.visible = estamina < estamina_max
	# verde si puede hacer dash, roja si el siguiente dash le dormiria
	if estamina >= coste_dash:
		$Barra.modulate = Color(0.4, 1.0, 0.4)
	else:
		$Barra.modulate = Color(1.0, 0.35, 0.35)
