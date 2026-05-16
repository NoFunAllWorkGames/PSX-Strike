@tool
extends Area3D

@export var generate_button: bool = false : set = _set_generate
@export var count: int = 100
@export var noise_strength: float = 10.0
@export var area_size: Vector3 = Vector3(20, 20, 20)

func _set_generate(_val: bool) -> void:
	clear_elements()
	setup_and_spawn()

func clear_elements() -> void:
	for child in get_children():
		if not child is CollisionShape3D:
			child.free()

func setup_and_spawn() -> void:
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.05
	
	var sphere_res = SphereMesh.new()
	sphere_res.radius = 0.5
	sphere_res.height = 1.0

	for i in range(count):
		# 1. Distribute points randomly within the 3D volume
		var x = randf_range(-area_size.x / 2, area_size.x / 2)
		var y = randf_range(-area_size.y / 2, area_size.y / 2)
		var z = randf_range(-area_size.z / 2, area_size.z / 2)
		
		# 2. Sample 3D Perlin noise at the point's coordinates
		var noise_val = noise.get_noise_3d(x, y, z)
		
		# 3. Apply noise strength to offset the position
		# This shifts the initial random point by the noise value (-1.0 to 1.0)
		var offset = Vector3(noise_val, noise_val, noise_val) * noise_strength
		var final_pos = Vector3(x, y, z) + offset
		
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = sphere_res
		add_child(mesh_instance)
		
		if Engine.is_editor_hint():
			mesh_instance.owner = get_tree().edited_scene_root
			
		mesh_instance.transform.origin = final_pos
