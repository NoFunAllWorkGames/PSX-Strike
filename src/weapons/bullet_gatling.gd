extends MultiMeshInstance3D

signal player_hit

@export var max_bullets: int = 5000
@export var bullet_lifetime: float = 4.0
@export_flags_3d_physics var player_collision_mask: int = 2

# Using parallel packed arrays for optimal cache locality and performance
var positions: PackedVector3Array = PackedVector3Array()
var velocities: PackedVector3Array = PackedVector3Array()
var times_alive: PackedFloat32Array = PackedFloat32Array()

func _ready() -> void:
	multimesh = multimesh.duplicate()
	multimesh.instance_count = max_bullets
	multimesh.visible_instance_count = 0

func spawn_bullet(start_position: Vector3, start_velocity: Vector3) -> void:
	# Enforce hard cap based on maximum multimesh instances allocated
	if positions.size() >= max_bullets:
		return

	positions.append(start_position)
	velocities.append(start_velocity)
	times_alive.append(0.0)

func _physics_process(delta: float) -> void:
	if GameManager.player_is_dead:
		return
	var bullet_count := positions.size()
	if bullet_count == 0:
		return

	# Loop backwards to safely remove elements without disrupting index tracking
	for i in range(bullet_count - 1, -1, -1):
		var time := times_alive[i] + delta

		# Time-based culling
		if time > bullet_lifetime:
			destroy_bullet(i)
			continue

		# Update life timer tracking array
		times_alive[i] = time

		# 2. Update position vector calculations
		var old_pos := positions[i]
		var new_pos := old_pos + (velocities[i] * delta)

		if _hits_player(old_pos, new_pos):
			player_hit.emit()
			destroy_bullet(i)
			continue

		positions[i] = new_pos

		# 3. Update Visual instance transform via RenderingServer pipeline
		var transform_3d := Transform3D(Basis(), new_pos)
		multimesh.set_instance_transform(i, transform_3d)

	# Sync visible count to the current size of the data vectors
	multimesh.visible_instance_count = positions.size()

func destroy_bullet(index: int) -> void:
	# Array removal shifts memory, fine for lower counts or sequential deletions
	positions.remove_at(index)
	velocities.remove_at(index)
	times_alive.remove_at(index)

func _hits_player(from_local: Vector3, end_local: Vector3) -> bool:
	if not is_instance_valid(GameManager.PlayerShip):
		return false

	var space_state := get_world_3d().direct_space_state
	if space_state == null:
		return false

	var query := PhysicsRayQueryParameters3D.create(to_global(from_local), to_global(end_local))
	query.collision_mask = player_collision_mask
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.hit_from_inside = true

	var result := space_state.intersect_ray(query)
	return not result.is_empty() and result.collider == GameManager.PlayerShip
