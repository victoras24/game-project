class_name DeathScreen
extends Control

func open() -> void:
	visible = true
	get_tree().paused = true
	
func _unhandled_input(event:InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().paused = false
		get_tree().reload_current_scene()
