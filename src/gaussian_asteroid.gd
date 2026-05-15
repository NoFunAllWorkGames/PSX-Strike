@tool
extends Area3D

@export_tool_button("Create Asteroids", "CreateIcon") var create_button = create_asteroids
@export_tool_button("Clear Asteroids", "ClearIcon") var clear_button = clear_asteroids
@export var count: int = 100
@export var spread: float = 50.0 # Replaces noise_strength

func _ready() -> void:
	if not Engine.is_editor_hint():
		tag_asteroid_children()

func create_asteroids() -> void:
	clear_asteroids()
	spawn_gaussian_cloud()

func clear_asteroids() -> void:
	for child in get_children():
		child.free()

func spawn_gaussian_cloud() -> void:
	var sphere_res = SphereMesh.new()
	sphere_res.radius = 0.5
	sphere_res.height = 1.0

	# Create the shape resource once to reuse for performance
	var collision_shape_res = SphereShape3D.new()
	collision_shape_res.radius = 0.5

	for i in range(count):
		var direction = Vector3(
			randfn(0, 1),
			randfn(0, 1),
			randfn(0, 1)
		).normalized()
		
		var distance = randfn(0, spread)
		var final_pos = direction * distance
		
		# Create Physics Body
		var static_body = StaticBody3D.new()
		static_body.collision_layer = 1
		static_body.collision_mask = 0
		
		# Create MeshInstance
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = sphere_res
		
		# Create CollisionShape
		var collision_shape = CollisionShape3D.new()
		collision_shape.shape = collision_shape_res
		
		# Assemble Hierarchy
		static_body.add_child(mesh_instance)
		static_body.add_child(collision_shape)
		add_child(static_body)
		tag_asteroid(static_body)

		if Engine.is_editor_hint():
			var root = get_tree().edited_scene_root
			static_body.owner = root
			mesh_instance.owner = root
			collision_shape.owner = root
			
		static_body.transform.origin = final_pos

func tag_asteroid_children() -> void:
	for child in get_children():
		if child is StaticBody3D:
			tag_asteroid(child)

func tag_asteroid(body: StaticBody3D) -> void:
	body.add_to_group("Asteroid")
