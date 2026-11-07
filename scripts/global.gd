extends Node

# los gatos, nombres y texturas en el mismo orden
const NOMBRES = ["Miguel", "Uma", "Tinsel", "Mati", "Кошка"]
const TEXTURAS = [
	preload("res://assets/sprites/gato_naranja.png"),
	preload("res://assets/sprites/gato_negro.png"),
	preload("res://assets/sprites/gato_blanco.png"),
	preload("res://assets/sprites/gato_gris.png"),
	preload("res://assets/sprites/gato_koshka.png"),
]

# los mismos gatos con los ojos cerrados, para cuando se duermen
const TEXTURAS_DORMIDO = [
	preload("res://assets/sprites/gato_naranja_dormido.png"),
	preload("res://assets/sprites/gato_negro_dormido.png"),
	preload("res://assets/sprites/gato_blanco_dormido.png"),
	preload("res://assets/sprites/gato_gris_dormido.png"),
	preload("res://assets/sprites/gato_koshka_dormido.png"),
]

# las pelotas: cada una es un diccionario (como un HashMap de java) con sus datos
# radio = tamaño de la colision, inicial/maxima = velocidades, aceleracion = por golpe
# rebote = velocidad extra al chocar (1.0 = nada), frenado = lo rapido que se pierde
const PELOTAS = [
	{
		"nombre": "Ovillo",
		"texto": "EL DE TODA LA VIDA",
		"textura": preload("res://assets/sprites/ovillo.png"),
		"radio": 13.0, "inicial": 380.0, "aceleracion": 1.035, "maxima": 600.0,
		"rebote": 1.3, "frenado": 3.0,
	},
	{
		"nombre": "Fútbol",
		"texto": "SALE DISPARADO PERO ACELERA POCO",
		"textura": preload("res://assets/sprites/pelota_futbol.png"),
		"radio": 13.0, "inicial": 430.0, "aceleracion": 1.02, "maxima": 600.0,
		"rebote": 1.4, "frenado": 3.0,
	},
	{
		"nombre": "Basket",
		"texto": "BOTA FUERTE Y LUEGO SE FRENA",
		"textura": preload("res://assets/sprites/pelota_basket.png"),
		"radio": 17.0, "inicial": 330.0, "aceleracion": 1.03, "maxima": 520.0,
		"rebote": 1.8, "frenado": 2.5,
	},
	{
		"nombre": "Béisbol",
		"texto": "PEQUEÑA Y SE DESBOCA",
		"textura": preload("res://assets/sprites/pelota_beisbol.png"),
		"radio": 10.0, "inicial": 380.0, "aceleracion": 1.05, "maxima": 720.0,
		"rebote": 1.1, "frenado": 4.0,
	},
]

# posicion en la lista del gato elegido por cada jugador
var gato1: int = 0
var gato2: int = 1
# pelota elegida
var pelota: int = 0
