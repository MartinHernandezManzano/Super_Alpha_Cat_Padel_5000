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

# posicion en la lista del gato elegido por cada jugador
var gato1: int = 0
var gato2: int = 1
