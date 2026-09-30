extends CharacterBody3D

@onready var head: Node3D = get_node("Head")
@onready var health_component: HealthComponent = get_node("HealthComponent")
@onready var weapons: Node3D = get_node("Head/Camera3D/Weapons")
@onready var camera: Camera3D = get_node("Head/Camera3D")
@onready var hud: HUD = get_node("CanvasLayer/Hud")
@onready var death_screen: DeathScreen = get_node("CanvasLayer/DeathScreen")

@export var jump_velocity: float = 5.0
@export var speed: float = 5.0
@export var sensitivity: float = 0.01

var recoil_tween: Tween
var weapon: Weapon

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for w in weapons.get_children():
		w.fired.connect(_on_weapon_fired)
		w.ammo_changed.connect(hud.update_ammo)
	hud.update_health(health_component.current_health, health_component.max_health)
	_equip(0)
	health_component.health_changed.connect(hud.update_health)
	health_component.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if not is_on_floor(): 
		velocity += get_gravity() * delta
	elif (Input.is_action_just_pressed("jump")):
		velocity.y = jump_velocity
	if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		if (Input.is_action_just_pressed("weapon_1")):
			_equip(0)
		if (Input.is_action_just_pressed("weapon_2")):
			_equip(1)
		if (Input.is_action_just_pressed("weapon_3")):
			_equip(2)
		if (Input.is_action_just_pressed("reload")):
			weapon.reload()
		if (weapon.is_automatic):
			if (Input.is_action_pressed("shoot")):
				weapon.shoot()
		else:
			if (Input.is_action_just_pressed("shoot")):
				weapon.shoot()
	var movement_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var movement_vector_3d: Vector3 = Vector3(movement_vector.x, 0, movement_vector.y)
	var direction: Vector3 = transform.basis * movement_vector_3d
	velocity.x = speed * direction.x
	velocity.z = speed * direction.z
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("debug_damage")):
		health_component.take_damage(10)
	if (event.is_action_pressed("release_mouse") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		if (event is InputEventMouseMotion): 
			rotate_y(-event.screen_relative.x * sensitivity)
			head.rotate_x(-event.screen_relative.y * sensitivity)
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	elif (event is InputEventMouseButton and event.is_released()):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
func _on_died() -> void:
	death_screen.open()
	
func _on_weapon_fired(camera_recoil: float) -> void:
	if recoil_tween:
		recoil_tween.kill()
	recoil_tween = create_tween()
	recoil_tween.tween_property(camera, "rotation:x", deg_to_rad(camera_recoil), 0.03)
	recoil_tween.tween_property(camera, "rotation:x", 0.00, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _equip(index: int) -> void:
	if weapon:
		weapon.holster()
	for w in weapons.get_children():
		w.visible = false
	weapon = weapons.get_child(index) as Weapon
	weapon.visible = true
	hud.update_ammo(weapon.current_ammo, weapon.magazine_size)
