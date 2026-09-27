extends Node3D

@export var lifetime: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer = get_tree().create_timer(lifetime);
	timer.timeout.connect(queue_free)
