class_name HitFlash
extends Node

@export var mesh: MeshInstance3D
@export var health_component: HealthComponent
@export var flash_color: Color = Color.WHITE

var tween: Tween
var original_color: Color

func _ready() -> void: 
	original_color = mesh.material_override.albedo_color
	health_component.damaged.connect(_on_damaged)

func _on_damaged() -> void:
	var mesh_material = mesh.material_override
	if (tween):
		tween.kill()
	tween = create_tween()
	tween.tween_property(mesh_material, "albedo_color", flash_color, 0.1)
	tween.tween_property(mesh_material, "albedo_color", original_color, 0.1)
