extends Node3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var laser_mesh: MeshInstance3D = $LaserMeshInstance
var damage_per_second = 100
var max_length = 100

# This is currently not using:
# mining_laser_data.gd
# mining_laser_res.tres

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
		if hit_object != null and hit_object.is_in_group("Asteroid") and hit_object is Asteroid:
			process_hit_object(hit_object as Asteroid, damage_per_second * delta)
	else:
		# If no collision, extend to maximum range
		target_point = ray_cast_3d.global_transform * Vector3(0, 0, -max_length)

	update_laser_geometry(target_point)

func process_hit_object(hit_object: Asteroid, damage: float) -> void:
	SignalBus.damage_asteroid.emit(hit_object, damage)

func update_laser_geometry(target_point: Vector3) -> void:
	var origin_point: Vector3 = ray_cast_3d.global_position
	var distance: float = origin_point.distance_to(target_point)
	
	# Make it long enough
	# CylinderMesh height is on the Y axis by default
	laser_mesh.mesh.height = distance
	
	# Pivot seems to be in the center
	# So move it to the end
	laser_mesh.position.z = -distance / 2.0
	
	# Aim the laser at the target
	if distance > 0.001:
		laser_mesh.look_at(target_point, Vector3.UP)
		# Rotate 90 degrees on X because CylinderMesh stands vertically (Y-up) by default
		laser_mesh.rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
