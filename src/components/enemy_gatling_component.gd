class_name EnemyGatlingComponent
extends Node3D

@export var rpm: float = 600.0 # Rounds per minute
@export var bullet_speed: float = 30.0
@export_range(0.0, 15.0, 0.1, "or_greater") var spread_degrees: float = 3.0
@export var bullet_gatling: MultiMeshInstance3D

@onready var hit_sound: AudioStreamPlayer = $HitSound
@onready var timer: Timer = $Timer

var is_firing: bool = false
# for carrier velocity compensation only
var _previous_global_position: Vector3
# for carrier velocity compensation only
var carrier_velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	_previous_global_position = global_position
	bullet_gatling = get_node("BulletGatling") as MultiMeshInstance3D
	bullet_gatling.player_hit.connect(_on_bullet_player_hit)

	# Configure and start the fire rate cycle
	timer.wait_time = 60.0 / rpm
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _physics_process(delta: float) -> void:
	# for carrier velocity compensation only
	if delta > 0.0:
		carrier_velocity = (global_position - _previous_global_position) / delta
	_previous_global_position = global_position

func _on_timer_timeout() -> void:
	if not is_firing:
		return

	if not is_instance_valid(bullet_gatling):
		return

	if not is_instance_valid(GameManager.PlayerShip):
		return

	var spawn_pos = calculate_bullet_origin()
	var bullet_velocity = calculate_bullet_velocity(spawn_pos)

	bullet_gatling.spawn_bullet(spawn_pos, bullet_velocity)

func calculate_bullet_origin() -> Vector3:
	return Vector3.FORWARD * 3.0

func calculate_bullet_velocity(spawn_pos: Vector3) -> Vector3:
	# start with the origin of the bullet in the world-space
	var spawn_pos_global = to_global(spawn_pos)

	# aim at the player in the world-space
	var heading_global: Vector3 = GameManager.PlayerShip.global_position - spawn_pos_global

	var aim_direction: Vector3 = heading_global.normalized()
	if spread_degrees > 0.0:
		aim_direction = _apply_cone_spread(aim_direction, deg_to_rad(spread_degrees))

	# compensate enemy ship movement
	var bullet_velocity_global: Vector3 = aim_direction * bullet_speed - carrier_velocity
	# convert world-space aim into the local-space
	var bullet_velocity: Vector3 = bullet_gatling.global_transform.basis.inverse() * bullet_velocity_global

	return bullet_velocity

# Magic math, has to be studied but works for now
func _apply_cone_spread(base_direction: Vector3, half_angle_rad: float) -> Vector3:
	var forward := base_direction.normalized()
	var reference := Vector3.UP if absf(forward.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT
	var tangent := forward.cross(reference).normalized()
	var bitangent := forward.cross(tangent)
	var axis := (tangent * cos(randf() * TAU) + bitangent * sin(randf() * TAU)).normalized()
	return forward.rotated(axis, randf() * half_angle_rad).normalized()

func _on_bullet_player_hit() -> void:
	hit_sound.play()
