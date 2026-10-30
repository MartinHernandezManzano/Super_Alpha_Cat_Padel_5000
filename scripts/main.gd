extends Node2D

func _ready() -> void:
	# arranca la cuenta atras de la ronda al empezar
	$RoundTimer.start()

func _on_player_interact_requested() -> void:
	print("Interacción recibida")
	# si el ovillo se esta moviendo lo para, y si esta parado lo reanuda
	$Ovillo.set_physics_process(not $Ovillo.is_physics_processing())
		# pausa o reanuda la cuenta atras junto con el ovillo
	$RoundTimer.paused = not $RoundTimer.paused

func _on_round_timer_timeout() -> void:
	# se acabo el tiempo: el gato deja de moverse y de escuchar el espacio
	$Player.set_physics_process(false)
	$Player.set_process_unhandled_input(false)
	# el ovillo tambien se para
	$Ovillo.set_physics_process(false)
	print("Fin de la ronda")
