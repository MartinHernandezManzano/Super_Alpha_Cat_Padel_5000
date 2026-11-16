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

# --- rugby: pelota alargada que gira y rebota segun por donde choque ---
# contorno del balon (rombo curvado), 40 x 25 px, centrado en 0,0
const PUNTOS_RUGBY = [
	Vector2(20.0, 0.0), Vector2(18.5, 2.9), Vector2(14.1, 7.4), Vector2(7.7, 11.0),
	Vector2(0.0, 12.4), Vector2(-7.7, 11.0), Vector2(-14.1, 7.4), Vector2(-18.5, 2.9),
	Vector2(-20.0, 0.0), Vector2(-18.5, -2.9), Vector2(-14.1, -7.4), Vector2(-7.7, -11.0),
	Vector2(0.0, -12.4), Vector2(7.7, -11.0), Vector2(14.1, -7.4), Vector2(18.5, -2.9),
]
const INERCIA_RUGBY: float = 120.0   # cuanto le cuesta girar, mas alto = gira menos
@export var friccion_rugby: float = 0.3      # cuanto agarra en la pared (el giro lo desvia)
@export var giro_maximo: float = 12.0        # radianes por segundo
@export var desvio_gato: float = 20.0        # grados maximos que se tuerce al darle un gato
var forma: String = "circulo"
var giro: float = 0.0        # velocidad de giro en radianes por segundo
# para no contar dos veces el mismo golpe (lo pueden detectar gato y ovillo a la vez)
var ultimo_gato = null
var tiempo_desde_golpe: float = 0.0

func _ready() -> void:
	velocidad = velocidad_inicial

func poner_pelota(datos: Dictionary) -> void:
	# cambia aspecto, tamaño y velocidades segun la pelota elegida
	$Sprite2D.texture = datos["textura"]
	# forma nueva para no tocar la que viene guardada en la escena
	forma = datos.get("forma", "circulo")
	if forma == "rugby":
		var poligono := ConvexPolygonShape2D.new()
		poligono.points = PackedVector2Array(PUNTOS_RUGBY)
		$CollisionShape2D.shape = poligono
	else:
		var circulo := CircleShape2D.new()
		circulo.radius = datos["radio"]
		$CollisionShape2D.shape = circulo
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
	if forma == "rugby":
		# gira sobre si mismo y el aire lo frena un poco
		rotation += giro * delta
		giro -= giro * 0.4 * delta
	var choque := move_and_collide(velocity * delta)
	if choque:
		var otro = choque.get_collider()
		if otro.is_in_group("gatos"):
			golpear(otro)
		else:
			# pared: el rugby rebota segun su forma, el resto como un espejo
			if forma == "rugby":
				rebote_rugby(choque)
			else:
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
	if forma == "rugby":
		direccion = golpe_rugby(direccion)
	velocity = direccion * velocidad
	botar()
	print("golpe de jugador ", gato.jugador, " velocidad: ", velocidad)
	toca_gato.emit(gato.jugador)
	
func parar() -> void:
	# deja el ovillo quieto esperando el saque
	velocity = Vector2.ZERO
	impulso = 0.0
	giro = 0.0
	rotation = 0.0
	ultimo_gato = null
	set_physics_process(false)

func sacar(direccion: Vector2, gato) -> void:
	# el saque cuenta como golpe del que saca y empieza a velocidad inicial
	velocidad = velocidad_inicial
	impulso = 0.0
	if forma == "rugby":
		giro = 4.0  # sale del saque ya girando
	velocity = direccion * velocidad
	ultimo_gato = gato
	tiempo_desde_golpe = 0.0
	set_physics_process(true)

func botar() -> void:
	# al chocar gana velocidad extra segun su rebote (con 1.0 no pasa nada)
	impulso = velocidad * (rebote - 1.0)
	velocity = velocity.normalized() * (velocidad + impulso)

func rebote_rugby(choque: KinematicCollision2D) -> void:
	# rebote de un cuerpo que gira: no es un espejo, depende de donde toque
	# si choca de punta, parte del golpe se va en giro y sale con un angulo raro
	# si choca de lado, rebota casi normal
	var n: Vector2 = choque.get_normal()
	var r: Vector2 = choque.get_position() - global_position  # del centro al punto de choque
	var v: Vector2 = velocity
	# velocidad del punto que choca = la de la pelota + la que le da el giro
	var v_punto: Vector2 = v + Vector2(-r.y, r.x) * giro
	var hacia_pared: float = v_punto.dot(n)
	if hacia_pared < 0:
		# empujon en la direccion de la normal (cuanto mas de punta, mas se reparte en giro)
		var brazo: float = r.cross(n)
		var empujon: float = -2.0 * hacia_pared / (1.0 + brazo * brazo / INERCIA_RUGBY)
		v += n * empujon
		giro += brazo * empujon / INERCIA_RUGBY
		# rozamiento con la pared: el giro la desvia hacia un lado
		var t := Vector2(-n.y, n.x)
		var brazo_t: float = r.cross(t)
		var roce: float = -v_punto.dot(t) / (1.0 + brazo_t * brazo_t / INERCIA_RUGBY)
		roce = clamp(roce, -friccion_rugby * empujon, friccion_rugby * empujon)
		v += t * roce
		giro += brazo_t * roce / INERCIA_RUGBY
	# que siempre salga despegandose de la pared, aunque sea poco
	var minimo: float = 0.3 * v.length()
	if v.dot(n) < minimo:
		v += n * (minimo - v.dot(n))
	velocity = v
	giro = clamp(giro, -giro_maximo, giro_maximo)

func golpe_rugby(direccion: Vector2) -> Vector2:
	# con los gatos se tuerce menos que en las paredes, para no perder el control
	# eje = hacia donde apunta la punta del balon ahora mismo
	var eje: Vector2 = Vector2.RIGHT.rotated(rotation)
	var lado: float = eje.cross(direccion)
	var frente: float = eje.dot(direccion)
	# de punta o de lado sale recto; de refilon (a 45 grados) es cuando mas se tuerce
	var desvio: float = 2.0 * lado * frente * deg_to_rad(desvio_gato)
	giro = clamp(giro + lado * 6.0, -giro_maximo, giro_maximo)
	return direccion.rotated(desvio)
