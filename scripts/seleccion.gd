extends Control

var listo1: bool = false
var listo2: bool = false
var cambiando: bool = false  # para no cargar el partido dos veces

func _ready() -> void:
	actualizar()

func _unhandled_input(event: InputEvent) -> void:
	if cambiando:
		return
	# jugador 1: rota si no esta listo, y con su saque marca o desmarca listo
	if not listo1:
		if event.is_action_pressed("p1_izquierda"):
			Global.gato1 = siguiente(Global.gato1, -1, Global.gato2)
		elif event.is_action_pressed("p1_derecha"):
			Global.gato1 = siguiente(Global.gato1, 1, Global.gato2)
	if event.is_action_pressed("p1_saque"):
		listo1 = not listo1
	# jugador 2: lo mismo con sus teclas
	if not listo2:
		if event.is_action_pressed("p2_izquierda"):
			Global.gato2 = siguiente(Global.gato2, -1, Global.gato1)
		elif event.is_action_pressed("p2_derecha"):
			Global.gato2 = siguiente(Global.gato2, 1, Global.gato1)
	if event.is_action_pressed("p2_saque"):
		listo2 = not listo2
	actualizar()
	if listo1 and listo2:
		empezar_partido()

func siguiente(actual: int, paso: int, ocupado: int) -> int:
	# avanza por la lista dando la vuelta al llegar al final
	var total: int = Global.NOMBRES.size()
	var nuevo: int = (actual + paso + total) % total
	# si es el gato del otro jugador se lo salta
	if nuevo == ocupado:
		nuevo = (nuevo + paso + total) % total
	return nuevo

func actualizar() -> void:
	actualizar_lado($Lados/Lado1, Global.gato1, listo1)
	actualizar_lado($Lados/Lado2, Global.gato2, listo2)

func actualizar_lado(lado: Node, gato: int, listo: bool) -> void:
	# la misma funcion sirve para los dos lados
	lado.get_node("Foto").texture = Global.TEXTURAS[gato]
	var nombre: String = Global.NOMBRES[gato].to_upper()
	if listo:
		lado.get_node("Nombre").text = nombre
		lado.get_node("Estado").text = "LISTO!"
	else:
		lado.get_node("Nombre").text = "< " + nombre + " >"
		lado.get_node("Estado").text = ""

func empezar_partido() -> void:
	cambiando = true
	# pausa cortita para que se vea el listo de los dos
	await get_tree().create_timer(0.6).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")
