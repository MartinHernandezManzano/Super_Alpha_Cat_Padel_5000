extends Node2D

func _on_player_interact_requested() -> void:
	print("Interacción recibida")
	$Ovillo.set_physics_process(not $Ovillo.is_physics_processing())
	
