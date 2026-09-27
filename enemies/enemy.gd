extends CharacterBody3D

enum State {IDLE, CHASE, ATTACK}

@export var movement_speed: float = 3.0
@export var detection_range: float = 10.0
@export var attack_range: float = 2.0
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.0

@onready var attack_timer: Timer = get_node("AttackTimer")
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var health_component: HealthComponent = get_node("HealthComponent")
@onready var sight_ray: RayCast3D = get_node("SightRay")

var state: State = State.IDLE
var player: Node3D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	health_component.died.connect(queue_free)
	
func _physics_process(delta: float) -> void:
	if not player:
		return
	if not is_on_floor(): 
		velocity += get_gravity() * delta
	var distance: float = global_position.distance_to(player.global_position)
	if (distance < attack_range):
		state = State.ATTACK
	elif (distance < detection_range and _can_see_player()):
		state = State.CHASE
	else:
		state = State.IDLE
	match state:
		State.CHASE:
			navigation_agent.set_target_position(player.global_position)
			var next_path_position: Vector3 = navigation_agent.get_next_path_position()
			var directions: Vector3 = next_path_position - global_position
			directions.y = 0
			var normalized_directions = directions.normalized()
			velocity.x = normalized_directions.x * movement_speed
			velocity.z = normalized_directions.z * movement_speed
		State.IDLE:
			velocity.x = 0
			velocity.z = 0
		State.ATTACK:
			velocity.x = 0
			velocity.z = 0
			_attack()
	move_and_slide()

func _attack() -> void:
	if (attack_timer.is_stopped()):
		attack_timer.start(attack_cooldown)
		var health: HealthComponent = player.get_node_or_null("HealthComponent")
		if (health):
			health.take_damage(attack_damage)

func _can_see_player() -> bool:
	sight_ray.target_position = sight_ray.to_local(player.global_position + Vector3.UP * 1.0)
	sight_ray.force_raycast_update() #without this the ray result is from the previous physics frame
	return sight_ray.get_collider() == player
