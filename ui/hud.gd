class_name HUD
extends Control

@onready var health_bar: ProgressBar = get_node("HealthBar")
@onready var ammo_label: Label = get_node("AmmoLabel")

func update_health(current_health: float, max_health: float) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health
	
func update_ammo(current_ammo: int, magazine_size: int) -> void:
	ammo_label.text = str(current_ammo) + "/" + str(magazine_size)
