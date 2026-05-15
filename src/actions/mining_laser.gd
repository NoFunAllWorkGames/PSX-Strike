extends Node3D

@export var max_length: float = 100.0
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var laser_mesh: MeshInstance3D = $LaserMeshInstance

func _ready() -> void:
	_update_raycast_length()

func _update_raycast_length() -> void:
	ray_cast_3d.target_position = Vector3(0, 0, -max_length)

func _physics_process(delta: float) -> void:
	var target_point: Vector3
	var hit_object
	
	if ray_cast_3d.is_colliding():
		target_point = ray_cast_3d.get_collision_point()
		hit_object = ray_cast_3d.get_collider()
		process_hit_object(hit_object)
	else:
		# If no collision, extend to maximum range
		target_point = ray_cast_3d.global_transform * Vector3(0, 0, -max_length)
	
	update_laser_geometry(target_point)

func process_hit_object(hit_object):
	if hit_object == null:
		return
	if hit_object.is_in_group("Asteroid"):
		hit_object.queue_free()

func update_laser_geometry(target_point: Vector3) -> void:
	var origin_point: Vector3 = ray_cast_3d.global_position
	var distance: float = origin_point.distance_to(target_point)
	
	# 1. Scale the mesh height along its local axis
	# Assuming a CylinderMesh, the height is on the Y axis by default
	laser_mesh.mesh.height = distance
	
	# 2. Position the mesh so the base stays at the origin
	# Move the mesh forward by half its length because Godot meshes center their pivot
	laser_mesh.position.z = -distance / 2.0
	
	# 3. Ensure the laser rotates to look at the target point
	if distance > 0.001:
		laser_mesh.look_at(target_point, Vector3.UP)
		# Rotate 90 degrees on X because CylinderMesh stands vertically (Y-up) by default
		laser_mesh.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
