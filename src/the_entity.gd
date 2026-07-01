extends Area3D

const SavedTheEntityStateResource := preload("res://src/data/saved_the_entity_state.gd")

const GROWTH_FACTOR := 1.06
const JITTER_RADIUS := 1.2
const ROTATION_JITTER := 0.25

@export var spawn_area: Area3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var growth_timer: Timer = $GrowthTimer
@onready var entity_audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

var _sphere_shape: SphereShape3D
var _base_radius: float
var _origin: Vector3
var _scale_tween: Tween
var _base_audio_unit_size: float
var _base_audio_max_distance: float


func _ready() -> void:
	_setup_mesh_and_collision()
	growth_timer.timeout.connect(_on_growth_timer_timeout)

	if GameManager.the_entity_pending_reset:
		reset_to_initial()
		GameManager.the_entity_pending_reset = false
		if GameManager.space_world_state != null:
			GameManager.space_world_state.the_entity = capture_state()
		return

	if GameManager.should_restore_space_world():
		if GameManager.space_world_state != null and GameManager.space_world_state.the_entity != null:
			apply_saved_state(GameManager.space_world_state.the_entity)
		return

	global_position = spawn_area.get_random_point()
	_origin = global_position


func _setup_mesh_and_collision() -> void:
	var sphere_mesh := mesh_instance.mesh as SphereMesh
	_base_radius = sphere_mesh.radius
	_sphere_shape = collision_shape.shape as SphereShape3D
	_base_audio_unit_size = entity_audio.unit_size
	_base_audio_max_distance = (
		entity_audio.max_distance if entity_audio.max_distance > 0.0
		else _base_audio_unit_size * 4.0
	)
	_sync_collision_to_mesh()


func capture_state() -> SavedTheEntityStateResource:
	var state := SavedTheEntityStateResource.new()
	state.origin = _origin
	state.scale = mesh_instance.scale
	return state


func apply_saved_state(state: SavedTheEntityStateResource) -> void:
	_origin = state.origin
	global_position = state.origin
	mesh_instance.scale = state.scale
	_sync_collision_to_mesh()


func reset_to_initial() -> void:
	if _scale_tween != null and _scale_tween.is_valid():
		_scale_tween.kill()
		_scale_tween = null

	mesh_instance.scale = Vector3.ONE
	_sync_collision_to_mesh()
	global_position = spawn_area.get_random_point()
	_origin = global_position


func _physics_process(_delta: float) -> void:
	if GameManager.player_is_dead:
		return
	global_position = _origin + _random_jitter_offset()
	mesh_instance.rotation = Vector3(
		randf_range(-ROTATION_JITTER, ROTATION_JITTER),
		randf_range(-ROTATION_JITTER, ROTATION_JITTER),
		randf_range(-ROTATION_JITTER, ROTATION_JITTER)
	)
	_check_player_collision()


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
	if _scale_tween != null and _scale_tween.is_valid():
		_scale_tween.kill()

	var target_scale := mesh_instance.scale * GROWTH_FACTOR
	_scale_tween = create_tween()
	_scale_tween.tween_method(_set_entity_scale, mesh_instance.scale, target_scale, growth_timer.wait_time)


func _set_entity_scale(new_scale: Vector3) -> void:
	mesh_instance.scale = new_scale
	_sync_collision_to_mesh()


func _sync_collision_to_mesh() -> void:
	var scale_factor := mesh_instance.scale.x
	_sphere_shape.radius = _base_radius * scale_factor
	_sync_audio_to_mesh(scale_factor)


func _sync_audio_to_mesh(scale_factor: float) -> void:
	entity_audio.unit_size = _base_audio_unit_size * scale_factor
	entity_audio.max_distance = _base_audio_max_distance * scale_factor


func _check_player_collision() -> void:
	if GameManager.player_is_dead:
		return
	if not is_instance_valid(GameManager.PlayerShip):
		return

	if get_overlapping_bodies().has(GameManager.PlayerShip):
		SignalBus.player_receive_damage.emit(1000)
