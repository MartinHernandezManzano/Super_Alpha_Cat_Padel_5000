extends Node2D

# altura de las esquinas de saque
const Y_ARRIBA: float = 120.0
const Y_ABAJO: float = 360.0
# x donde se colocan los gatos y el ovillo en el saque
const X_GATO1: float = 150.0
const X_GATO2: float = 810.0
const X_OVILLO1: float = 205.0
const X_OVILLO2: float = 755.0
# x de la red, a la izquierda es el campo del 1 y a la derecha el del 2
const X_RED: float = 480.0

var sacador: int = 1
var puntos_jugados: int = 0
var esperando_saque: bool = true

# estado del punto para aplicar las reglas
var en_juego: bool = false
var campo: int = 1                   # campo donde esta el ovillo
var paredes: int = 0                 # paredes tocadas en ese campo
var dueno_ha_golpeado: bool = false  # si el gato de ese campo lo ha tocado
var ultimo_golpeador: int = 0
var puntos1: int = 0
var puntos2: int = 0

func _ready() -> void:
	# conectamos por codigo las señales del ovillo
	$Ovillo.toca_pared.connect(_on_ovillo_toca_pared)
	$Ovillo.toca_gato.connect(_on_ovillo_toca_gato)
		# marcador grande oculto y textos a 0
	$HUD/Resumen.visible = false
	actualizar_textos()
	preparar_saque()

func _physics_process(_delta: float) -> void:
	if not en_juego:
		return
	# regla 2: mirar si el ovillo ha cambiado de campo
	var nuevo_campo := campo_del_ovillo()
	if nuevo_campo != campo:
		if not dueno_ha_golpeado:
			fin_de_punto(rival(campo), "sale del campo " + str(campo) + " sin que su gato lo toque")
			return
		# cruce valido: empieza la cuenta en el campo nuevo
		campo = nuevo_campo
		paredes = 0
		dueno_ha_golpeado = false

func _on_ovillo_toca_pared() -> void:
	if not en_juego:
		return
	# regla 1: dos paredes en el mismo campo
	paredes += 1
	if paredes >= 2:
		fin_de_punto(rival(campo), "dos paredes en el campo " + str(campo))

func _on_ovillo_toca_gato(jugador: int) -> void:
	if not en_juego:
		return
	# regla 3: el mismo gato no puede tocarlo dos veces seguidas
	if jugador == ultimo_golpeador:
		fin_de_punto(rival(jugador), "doble toque del jugador " + str(jugador))
		return
	ultimo_golpeador = jugador
	paredes = 0
	dueno_ha_golpeado = true

func campo_del_ovillo() -> int:
	if $Ovillo.position.x < X_RED:
		return 1
	return 2

func rival(jugador: int) -> int:
	if jugador == 1:
		return 2
	return 1

func preparar_saque() -> void:
	esperando_saque = true
	# puntos 0 y 1 saca el 1, puntos 2 y 3 saca el 2, y vuelta a empezar
	if puntos_jugados % 4 < 2:
		sacador = 1
	else:
		sacador = 2
	# la esquina cambia en cada punto: par arriba, impar abajo
	var y_saque: float = Y_ARRIBA
	var y_resto: float = Y_ABAJO
	if puntos_jugados % 2 == 1:
		y_saque = Y_ABAJO
		y_resto = Y_ARRIBA
	# coloca a cada uno en su sitio: el que resta en la diagonal contraria
	if sacador == 1:
		$Player1.position = Vector2(X_GATO1, y_saque)
		$Player2.position = Vector2(X_GATO2, y_resto)
		$Ovillo.position = Vector2(X_OVILLO1, y_saque)
	else:
		$Player2.position = Vector2(X_GATO2, y_saque)
		$Player1.position = Vector2(X_GATO1, y_resto)
		$Ovillo.position = Vector2(X_OVILLO2, y_saque)
	$Ovillo.parar()
	$Player1.set_physics_process(false)
	$Player2.set_physics_process(false)
	print("saca el jugador ", sacador)

func _on_player_interact_requested(jugador: int) -> void:
	if not esperando_saque or jugador != sacador:
		return
	esperando_saque = false
	var gato_saca = $Player1
	var gato_resta = $Player2
	if sacador == 2:
		gato_saca = $Player2
		gato_resta = $Player1
	var direccion: Vector2 = (gato_resta.position - $Ovillo.position).normalized()
	$Ovillo.sacar(direccion, gato_saca)
	# el saque cuenta como primer golpe del que saca
	en_juego = true
	campo = sacador
	paredes = 0
	dueno_ha_golpeado = true
	ultimo_golpeador = sacador
	$Player1.set_physics_process(true)
	$Player2.set_physics_process(true)

func fin_de_punto(ganador: int, motivo: String) -> void:
	en_juego = false
	$Ovillo.parar()
	$Player1.set_physics_process(false)
	$Player2.set_physics_process(false)
	print("PUNTO para el jugador ", ganador, " -> ", motivo)
	# animacion del marcador, espera a que termine antes de seguir
	await mostrar_punto(ganador)
	puntos_jugados += 1
	preparar_saque()
	
func mostrar_punto(ganador: int) -> void:
	# cambia el marcador pequeño por el grande
	$HUD/MarcadorPeq.visible = false
	$HUD/Resumen.visible = true
	var numero: Label = $HUD/Resumen/Numeros/Puntos1
	if ganador == 2:
		numero = $HUD/Resumen/Numeros/Puntos2
	await espera(0.6)
	# parpadea el numero viejo, suma el punto y parpadea el nuevo
	await parpadear(numero, 3)
	if ganador == 1:
		puntos1 += 1
	else:
		puntos2 += 1
	actualizar_textos()
	await parpadear(numero, 4)
	await espera(1.0)
	# vuelta al marcador pequeño
	$HUD/Resumen.visible = false
	$HUD/MarcadorPeq.visible = true

func parpadear(label: Label, veces: int) -> void:
	# lo hacemos transparente y opaco en vez de ocultarlo
	# asi el hbox no recoloca los numeros en cada parpadeo
	for i in veces:
		label.modulate.a = 0.0
		await espera(0.12)
		label.modulate.a = 1.0
		await espera(0.12)

func espera(segundos: float) -> void:
	await get_tree().create_timer(segundos).timeout

func actualizar_textos() -> void:
	$HUD/Resumen/Numeros/Puntos1.text = str(puntos1)
	$HUD/Resumen/Numeros/Puntos2.text = str(puntos2)
	$HUD/MarcadorPeq.text = str(puntos1) + " - " + str(puntos2)
