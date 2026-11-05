extends Control

# rangos para pasar los numeros de cada pelota a estrellas (1 a 5)
const RANGO_INICIAL = [320.0, 440.0]
const RANGO_MAXIMA = [500.0, 740.0]
const RANGO_ACELERACION = [1.015, 1.055]
const RANGO_RADIO = [9.0, 18.0]

var cambiando: bool = false  # para no cargar el partido dos veces

func _ready() -> void:
	actualizar()

func _unhandled_input(event: InputEvent) -> void:
	if cambiando:
		return
	# cualquiera de los dos jugadores puede cambiar la pelota
	if event.is_action_pressed("p1_izquierda") or event.is_action_pressed("p2_izquierda"):
		cambiar(-1)
	elif event.is_action_pressed("p1_derecha") or event.is_action_pressed("p2_derecha"):
		cambiar(1)
	# y cualquiera de los dos la confirma
	elif event.is_action_pressed("p1_saque") or event.is_action_pressed("p2_saque"):
		empezar_partido()

func cambiar(paso: int) -> void:
	# avanza por la lista dando la vuelta, igual que con los gatos
	var total: int = Global.PELOTAS.size()
	Global.pelota = (Global.pelota + paso + total) % total
	actualizar()

func actualizar() -> void:
	var datos: Dictionary = Global.PELOTAS[Global.pelota]
	$Centro/Foto.texture = datos["textura"]
	$Centro/Nombre.text = "< " + datos["nombre"].to_upper() + " >"
	$Centro/Texto.text = datos["texto"]
	# todas las lineas igual de largas para que queden alineadas
	var stats: String = ""
	stats += "SALIDA   " + estrellas(datos["inicial"], RANGO_INICIAL) + "\n"
	stats += "TOPE     " + estrellas(datos["maxima"], RANGO_MAXIMA) + "\n"
	stats += "ACELERA  " + estrellas(datos["aceleracion"], RANGO_ACELERACION) + "\n"
	stats += "TAMAÑO   " + estrellas(datos["radio"], RANGO_RADIO)
	$Centro/Stats.text = stats

func estrellas(valor: float, rango: Array) -> String:
	# convierte el valor en 1 a 5 estrellas segun donde caiga dentro del rango
	var proporcion: float = (valor - rango[0]) / (rango[1] - rango[0])
	var llenas: int = clampi(int(round(proporcion * 4)) + 1, 1, 5)
	var texto: String = ""
	for i in 5:
		if i < llenas:
			texto += "★"
		else:
			texto += "☆"
	return texto

func empezar_partido() -> void:
	cambiando = true
	$Centro/Nombre.text = datos_nombre() + " !"
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func datos_nombre() -> String:
	return Global.PELOTAS[Global.pelota]["nombre"].to_upper()
