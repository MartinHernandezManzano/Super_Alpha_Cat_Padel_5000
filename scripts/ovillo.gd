extends CharacterBody2D

# el ovillo avisa de lo que le pasa, main decide si es punto
signal toca_pared
signal toca_gato(jugador: int)

@export var velocidad_inicial: float = 380.0
# cada golpe de gato multiplica la velocidad por esto (1.04 = +4%)
@export var aceleracion: float = 1.035
@export var velocidad_maxima: float = 600.0

var velocidad: float
# para no contar dos veces el mismo golpe (lo pueden detectar gato y ovillo a la vez)
var ultimo_gato = null
var tiempo_desde_golpe: float = 0.0

func _ready() -> void:
	velocidad = velocidad_inicial
	

func _physics_process(delta: float) -> void:
	tiempo_desde_golpe += delta
	var choque := move_and_collide(velocity * delta)
	if choque:
		var otro = choque.get_collider()
		if otro.is_in_group("gatos"):
			golpear(otro)
		else:
			# pared o red: rebote normal
			velocity = velocity.bounce(choque.get_normal())
			toca_pared.emit()

func golpear(gato) -> void:
	# si es el mismo gato hace nada, es el mismo golpe detectado dos veces
	if gato == ultimo_gato and tiempo_desde_golpe < 0.2:
		return
	ultimo_gato = gato
	tiempo_desde_golpe = 0.0
	# acelera un poco sin pasarse del maximo
	velocidad = min(velocidad * aceleracion, velocidad_maxima)
	# estilo air hockey: sale en la direccion del centro del gato hacia el ovillo
	var direccion: Vector2 = (global_position - gato.global_position).normalized()
	velocity = direccion * velocidad
	print("golpe de jugador ", gato.jugador, " velocidad: ", velocidad)
	toca_gato.emit(gato.jugador)
	
func parar() -> void:
	# deja el ovillo quieto esperando el saque
	velocity = Vector2.ZERO
	ultimo_gato = null
	set_physics_process(false)

func sacar(direccion: Vector2, gato) -> void:
	# el saque cuenta como golpe del que saca y empieza a velocidad inicial
	velocidad = velocidad_inicial
	velocity = direccion * velocidad
	ultimo_gato = gato
	tiempo_desde_golpe = 0.0
	set_physics_process(true)
