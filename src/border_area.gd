extends Area3D

@onready var player_ship: CharacterBody3D = GameManager.PlayerShip
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	body_exited.connect(_on_body_exited)
	spawn_debug_marker_with_label(get_random_point_on_any_edge(), "1")
	spawn_debug_marker_with_label(get_random_point_on_any_edge(), "2")
	spawn_debug_marker_with_label(get_random_point_on_any_edge(), "3")
	spawn_debug_marker_with_label(get_random_point_on_any_edge(), "4")
	spawn_debug_marker_with_label(get_random_point_on_any_edge(), "5")
	spawn_debug_marker_with_label(get_random_point_on_any_edge(), "6")
	spawn_debug_marker_with_label(get_random_point_on_any_edge(), "7")
	spawn_debug_marker_with_label(get_random_point_on_any_edge(), "8")
	spawn_debug_marker_with_label(get_random_point_on_any_edge(), "9")
	spawn_debug_marker_with_label(get_random_point_on_any_edge(), "10")

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

func get_random_point_on_any_edge() -> Vector3:
	var edges: PackedVector3Array = create_area_edge_segments()
	
	# Verify that the array contains valid edge data
	if edges.is_empty():
		return Vector3.ZERO
		
	# 1. Calculate the total number of distinct edges (24 vertices / 2 = 12 edges)
	var total_edges: int = edges.size() / 2
	
	# 2. Select a random edge index between 0 and 11
	var random_edge_index: int = randi() % total_edges
	
	# 3. Retrieve the start and end global positions for the selected edge
	var start_idx: int = random_edge_index * 2
	var edge_start: Vector3 = edges[start_idx]
	var edge_end: Vector3 = edges[start_idx + 1]
	
	# 4. Pick a random interpolation factor between 0.0 (start) and 1.0 (end)
	var random_weight: float = randf()
	
	# 5. Linearly interpolate between the two points to find the position in world space
	var random_point: Vector3 = edge_start.lerp(edge_end, random_weight)
	
	return random_point

func spawn_debug_marker_with_label(position_3d: Vector3, label_text: String):
	# 1. Instantiate the base marker (Sphere)
	var marker = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.2
	sphere_mesh.height = 0.4
	marker.mesh = sphere_mesh

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0, 0) # Red
	material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	marker.material_override = material

	# Position the sphere at the exact coordinate
	marker.position = position_3d
	add_child(marker)

	# 2. Instantiate the text label
	var label = Label3D.new()
	label.text = label_text
	label.fixed_size = true
	label.font_size = 8
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true

	# Position the label slightly above the sphere (Y-axis offset)
	var offset_y = 0.5
	label.position = position_3d + Vector3(0, offset_y, 0)
	add_child(label)

func get_random_direction_vector() -> Vector3:
	var edge_points: PackedVector3Array = create_area_edge_segments()

	var edge1 := randi() % edge_points.size()
	var edge2 := randi() % edge_points.size()

	var point1: Vector3 = edge_points[edge1]
	var point2: Vector3 = edge_points[edge2]

	var direction_vector: Vector3 = (point2 - point1).normalized()
	return direction_vector
