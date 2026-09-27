class_name HealthComponent
extends Node

signal damaged
signal health_changed(current_health: float, max_health: float)
signal died

@export var max_health: float = 100.0
var current_health: float

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	if (current_health <= 0):
		return
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	damaged.emit()
	health_changed.emit(current_health, max_health)
	if (current_health <= 0):
		died.emit()
		
