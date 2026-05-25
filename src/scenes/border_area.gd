extends Area3D

var player_ship: CharacterBody3D = GameManager.PlayerShip
@export var collision_shape_3d: CollisionShape3D


func _ready() -> void:
	body_exited.connect(_on_body_exited)

func _on_body_exited(body: Node3D):
	if body == player_ship:
		print("Exited")

func create_area_edge_segments() -> PackedVector3Array:
	var shape = collision_shape_3d.shape
	var mesh = shape.get_debug_mesh()
	var aabb = mesh.get_aabb()

	# Derive extents from the AABB size property
	var extents: Vector3 = aabb.size / 2.0

	# Define the 8 specific corner vertices in local space
	var c0 := Vector3(-extents.x, -extents.y, -extents.z) # Bottom-Left-Back
	var c1 := Vector3( extents.x, -extents.y, -extents.z) # Bottom-Right-Back
	var c2 := Vector3( extents.x,  extents.y, -extents.z) # Top-Right-Back
	var c3 := Vector3(-extents.x,  extents.y, -extents.z) # Top-Left-Back
	var c4 := Vector3(-extents.x, -extents.y,  extents.z) # Bottom-Left-Front
	var c5 := Vector3( extents.x, -extents.y,  extents.z) # Bottom-Right-Front
	var c6 := Vector3( extents.x,  extents.y,  extents.z) # Top-Right-Front
	var c7 := Vector3(-extents.x,  extents.y,  extents.z) # Top-Left-Front

	# Construct the 12 explicit edges as pairs (Start, End)
	var local_segments: Array[Vector3] = [
		# --- BACK FACE EDGES ---
		c0, c1, # Bottom edge
		c1, c2, # Right edge
		c2, c3, # Top edge
		c3, c0, # Left edge

		# --- FRONT FACE EDGES ---
		c4, c5, # Bottom edge
		c5, c6, # Right edge
		c6, c7, # Top edge
		c7, c4, # Left edge

		# --- CONNECTING SIDE EDGES (Back to Front) ---
		c0, c4, # Bottom-Left edge
		c1, c5, # Bottom-Right edge
		c2, c6, # Top-Right edge
		c3, c7  # Top-Left edge
	]

	# Transform all points to global world space and populate the PackedVector3Array
	var global_segments := PackedVector3Array()
	global_segments.resize(local_segments.size())

	# Fixed reference from shape_node to collision_shape_3d
	var mat: Transform3D = collision_shape_3d.global_transform
	for i in range(local_segments.size()):
		global_segments[i] = mat * local_segments[i]

	return global_segments

## Uniform on box hull: face weighted by area, then two uniforms on that face (shape-local AABB).
func get_random_point_on_box_surface() -> Vector3:
	var shape := collision_shape_3d.shape
	var mesh := shape.get_debug_mesh()
	var aabb := mesh.get_aabb()
	var size_dimensions_aabb := aabb.size
	if size_dimensions_aabb.x <= 0.0 or size_dimensions_aabb.y <= 0.0 or size_dimensions_aabb.z <= 0.0:
		return collision_shape_3d.global_position

	var start_corner_aabb := aabb.position
	var end_corner_aabb := start_corner_aabb + size_dimensions_aabb
	var transformation := collision_shape_3d.global_transform

	var wx: float = size_dimensions_aabb.y * size_dimensions_aabb.z
	var wy: float = size_dimensions_aabb.x * size_dimensions_aabb.z
	var wz: float = size_dimensions_aabb.x * size_dimensions_aabb.y
	var total: float = 2.0 * (wx + wy + wz)
	var r: float = randf() * total

	var local: Vector3
	if r < wx:
		local = Vector3(start_corner_aabb.x, start_corner_aabb.y + randf() * size_dimensions_aabb.y, start_corner_aabb.z + randf() * size_dimensions_aabb.z)
	elif r < 2.0 * wx:
		local = Vector3(end_corner_aabb.x, start_corner_aabb.y + randf() * size_dimensions_aabb.y, start_corner_aabb.z + randf() * size_dimensions_aabb.z)
	elif r < 2.0 * wx + wy:
		local = Vector3(start_corner_aabb.x + randf() * size_dimensions_aabb.x, start_corner_aabb.y, start_corner_aabb.z + randf() * size_dimensions_aabb.z)
	elif r < 2.0 * wx + 2.0 * wy:
		local = Vector3(start_corner_aabb.x + randf() * size_dimensions_aabb.x, end_corner_aabb.y, start_corner_aabb.z + randf() * size_dimensions_aabb.z)
	elif r < 2.0 * wx + 2.0 * wy + wz:
		local = Vector3(start_corner_aabb.x + randf() * size_dimensions_aabb.x, start_corner_aabb.y + randf() * size_dimensions_aabb.y, start_corner_aabb.z)
	else:
		local = Vector3(start_corner_aabb.x + randf() * size_dimensions_aabb.x, start_corner_aabb.y + randf() * size_dimensions_aabb.y, end_corner_aabb.z)

	return transformation * local


func get_random_point() -> Vector3:
	if collision_shape_3d == null:
		return global_position

	var mesh := collision_shape_3d.shape.get_debug_mesh()
	var aabb := mesh.get_aabb()
	var start_corner_aabb := aabb.position
	var size_dimensions_aabb := aabb.size
	var local := Vector3(
		start_corner_aabb.x + randf() * size_dimensions_aabb.x,
		start_corner_aabb.y + randf() * size_dimensions_aabb.y,
		start_corner_aabb.z + randf() * size_dimensions_aabb.z
	)
	return collision_shape_3d.global_transform * local


func get_random_direction_vector(start_point: Vector3) -> Vector3:
	if collision_shape_3d == null:
		return Vector3.FORWARD
	var p2 := get_random_point_on_box_surface()
	var chord := p2 - start_point
	if chord.length_squared() < 1e-12:
		return (collision_shape_3d.global_position - start_point).normalized()
	var toward_center := collision_shape_3d.global_position - start_point
	if chord.dot(toward_center) < 0.0:
		chord = -chord
	return chord.normalized()
