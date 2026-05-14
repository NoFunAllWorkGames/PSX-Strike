@tool
extends Area3D

@export var generate_button: bool = false : set = _set_generate
@export var count: int = 100
@export var spread: float = 50.0 # Replaces noise_strength

func _set_generate(_val: bool) -> void:
	clear_elements()
	spawn_gaussian_cloud()

func clear_elements() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			child.free()

func spawn_gaussian_cloud() -> void:
	var sphere_res = SphereMesh.new()
	sphere_res.radius = 0.5
	sphere_res.height = 1.0

	for i in range(count):
		# Generate a random direction vector on a unit sphere
		var direction = Vector3(
			randfn(0, 1),
			randfn(0, 1),
			randfn(0, 1)
		).normalized()
		
		# randfn(mean, deviation) creates the "clumping" effect
		# Most values will be near 0, fewer will be near the 'spread'
		var distance = randfn(0, spread)
		
		var final_pos = direction * distance
		
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = sphere_res
		add_child(mesh_instance)
		
		if Engine.is_editor_hint():
			mesh_instance.owner = get_tree().edited_scene_root
			
		mesh_instance.transform.origin = final_pos
