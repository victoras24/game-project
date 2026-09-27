extends StaticBody3D

@onready var health_component: HealthComponent = get_node("HealthComponent")

func _ready() -> void: 
	health_component.died.connect(queue_free)
