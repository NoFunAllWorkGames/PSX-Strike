extends Area3D

const GROWTH_FACTOR := 1.1
const JITTER_RADIUS := 1.2
const ROTATION_JITTER := 0.25

@export var spawn_area: Area3D
@export_range(0.0, 0.1) var distortion_intensity: float = 0.021

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var growth_timer: Timer = $GrowthTimer

var _sphere_shape: SphereShape3D
var _base_radius: float
var _origin: Vector3


func _ready() -> void:
	global_position = spawn_area.get_random_point()

	_origin = global_position

	var sphere_mesh := mesh_instance.mesh as SphereMesh
	(sphere_mesh.material as ShaderMaterial).set_shader_parameter("distortion_intensity", distortion_intensity)
	_base_radius = sphere_mesh.radius

	_sphere_shape = collision_shape.shape as SphereShape3D
	_sync_collision_to_mesh()

	growth_timer.timeout.connect(_on_growth_timer_timeout)


func _physics_process(_delta: float) -> void:
	if GameManager.player_is_dead:
		return
	global_position = _origin + _random_jitter_offset()
	mesh_instance.rotation = Vector3(
		randf_range(-ROTATION_JITTER, ROTATION_JITTER),
		randf_range(-ROTATION_JITTER, ROTATION_JITTER),
		randf_range(-ROTATION_JITTER, ROTATION_JITTER)
	)


func _random_jitter_offset() -> Vector3:
	var direction := Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	)
	if direction.length_squared() < 0.001:
		return Vector3.ZERO

	return direction.normalized() * randf_range(JITTER_RADIUS * 0.35, JITTER_RADIUS)


func _on_growth_timer_timeout() -> void:
	mesh_instance.scale *= GROWTH_FACTOR
	_sync_collision_to_mesh()
	_check_player_collision()


func _sync_collision_to_mesh() -> void:
	_sphere_shape.radius = _base_radius * mesh_instance.scale.x


func _check_player_collision() -> void:
	if GameManager.player_is_dead:
		return
	if not is_instance_valid(GameManager.PlayerShip):
		return

	if get_overlapping_bodies().has(GameManager.PlayerShip):
		SignalBus.player_receive_damage.emit(1000)
