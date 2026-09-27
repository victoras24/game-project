class_name Weapon
extends Node3D

signal fired(camera_recoil: float)
signal ammo_changed(current_ammo: int, magazine_size: int)

@onready var reload_timer: Timer = get_node("ReloadTimer")
@onready var shoot_timer: Timer = get_node("ShootTimer")
@onready var mesh: MeshInstance3D = get_node("MeshInstance3D")
@onready var shot_sound: AudioStreamPlayer = get_node("ShotSound")
@onready var empty_sound: AudioStreamPlayer = get_node("EmptySound")
@onready var reload_sound: AudioStreamPlayer = get_node("ReloadSound")

@export var raycast: RayCast3D
@export var damage: float = 10.0
@export var fire_cooldown: float = 0.1
@export var is_automatic: bool = true
@export var impact_scene: PackedScene
@export var magazine_size: int = 12
@export var reload_time: float = 1.16
@export var kick_distance: float = 0.05
@export var camera_recoil: float = 1.5
@export var pellet_count: int = 1 
@export var spread: float = 0.0

var kick_tween: Tween
var current_ammo: int
var base_target: Vector3

func _ready() -> void:
	current_ammo = magazine_size
	base_target = raycast.target_position
	reload_timer.timeout.connect(_on_reload_finished)

func shoot() -> void:
	if not reload_timer.is_stopped():
		return
	if current_ammo <= 0:
		if not empty_sound.playing:
			empty_sound.play()
		return
	if (shoot_timer.is_stopped()):
		shoot_timer.start(fire_cooldown)
		current_ammo -= 1
		ammo_changed.emit(current_ammo, magazine_size)
		if kick_tween:
			kick_tween.kill()
		kick_tween = create_tween()
		kick_tween.tween_property(mesh, "position:z", kick_distance, 0.03)
		kick_tween.tween_property(mesh, "position:z", 0.00, 0.07).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		fired.emit(camera_recoil)
		shot_sound.pitch_scale = randf_range(0.95, 1.05)
		shot_sound.play()
		for i in pellet_count:
			var angle_x = randf_range(-spread, spread)
			var angle_y = randf_range(-spread, spread)
			raycast.target_position = base_target.rotated(Vector3.UP, deg_to_rad(angle_y)).rotated(Vector3.RIGHT, deg_to_rad(angle_x))
			raycast.force_raycast_update()
			if (raycast.is_colliding()):
				var collider: Node = raycast.get_collider()
				var impact: Node3D = impact_scene.instantiate()
				collider.add_child(impact)
				impact.global_position = raycast.get_collision_point()
				var health: HealthComponent = collider.get_node_or_null("HealthComponent")
				if (health):
					health.take_damage(damage)
		raycast.target_position = base_target

func reload() -> void:
	if not reload_timer.is_stopped():
		return
	if current_ammo >= magazine_size:
		return
	reload_timer.start(reload_time)
	reload_sound.play()
	print("reloading...")

func _on_reload_finished() -> void:
	current_ammo = magazine_size
	ammo_changed.emit(current_ammo, magazine_size)
	
func holster() -> void:
	reload_timer.stop()
	reload_sound.stop()
