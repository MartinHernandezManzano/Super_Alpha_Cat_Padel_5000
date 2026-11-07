extends CharacterBody2D

# el ovillo avisa de lo que le pasa, main decide si es punto
signal toca_pared
signal toca_gato(jugador: int)

@export var velocidad_inicial: float = 380.0
# cada golpe de gato multiplica la velocidad por esto (1.04 = +4%)
@export var aceleracion: float = 1.035
@export var velocidad_maxima: float = 600.0

var velocidad: float
# tamaño de la pelota, main lo usa para saber si ha cruzado la red entera
var radio: float = 13.0
# bote: al chocar sale mas rapido de lo normal y luego se va frenando
# rebote 1.0 = sin bote extra, 1.7 = sale un 70% mas rapido
var rebote: float = 1.0
var frenado: float = 3.0     # lo rapido que se pierde el bote, mas alto = frena antes
var impulso: float = 0.0     # velocidad extra del ultimo bote
# para no contar dos veces el mismo golpe (lo pueden detectar gato y ovillo a la vez)
var ultimo_gato = null
var tiempo_desde_golpe: float = 0.0

func _ready() -> void:
	velocidad = velocidad_inicial

func poner_pelota(datos: Dictionary) -> void:
	# cambia aspecto, tamaño y velocidades segun la pelota elegida
	$Sprite2D.texture = datos["textura"]
	# forma nueva para no tocar la que viene guardada en la escena
	var forma := CircleShape2D.new()
	forma.radius = datos["radio"]
	$CollisionShape2D.shape = forma
	radio = datos["radio"]
	rebote = datos["rebote"]
	frenado = datos["frenado"]
	velocidad_inicial = datos["inicial"]
	aceleracion = datos["aceleracion"]
	velocidad_maxima = datos["maxima"]
	velocidad = velocidad_inicial

func _physics_process(delta: float) -> void:
	tiempo_desde_golpe += delta
	# el bote se va perdiendo poco a poco
	impulso -= impulso * frenado * delta
	velocity = velocity.normalized() * (velocidad + impulso)
	var choque := move_and_collide(velocity * delta)
	if choque:
		var otro = choque.get_collider()
		if otro.is_in_group("gatos"):
			golpear(otro)
		else:
			# pared o red: rebote normal
			velocity = velocity.bounce(choque.get_normal())
			botar()
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
	botar()
	print("golpe de jugador ", gato.jugador, " velocidad: ", velocidad)
	toca_gato.emit(gato.jugador)
	
func parar() -> void:
	# deja el ovillo quieto esperando el saque
	velocity = Vector2.ZERO
	impulso = 0.0
	ultimo_gato = null
	set_physics_process(false)

func sacar(direccion: Vector2, gato) -> void:
	# el saque cuenta como golpe del que saca y empieza a velocidad inicial
	velocidad = velocidad_inicial
	impulso = 0.0
	velocity = direccion * velocidad
	ultimo_gato = gato
	tiempo_desde_golpe = 0.0
	set_physics_process(true)

func botar() -> void:
	# al chocar gana velocidad extra segun su rebote (con 1.0 no pasa nada)
	impulso = velocidad * (rebote - 1.0)
	velocity = velocity.normalized() * (velocidad + impulso)
