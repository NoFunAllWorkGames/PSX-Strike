extends RigidBody3D
class_name Asteroid

# No defaults, this is currently only set in
# spawn_gaussian_cloud
@export var max_health: float
@export var health: float
@export var gained_resource: int
@export var mesh_seed: int = -1

const ProceduralAsteroidMeshBuilder := preload("res://src/utils/procedural_asteroid_mesh.gd")
var asteroid_pickup = preload("res://scenes/Objects/asteroid_pickup.tscn")

@onready var _mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D
@onready var _damage_bar = $DamageBar


func _ready() -> void:
	if mesh_seed < 0:
		mesh_seed = randi()
	_apply_procedural_mesh()


func _apply_procedural_mesh() -> void:
	var mesh: ArrayMesh = ProceduralAsteroidMeshBuilder.build(mesh_seed)
	_mesh_instance.mesh = mesh
	_collision_shape.shape = mesh.create_convex_shape()

func take_damage(applied_damage: float) -> void:
	health -= applied_damage
	_damage_bar.show_health()
	if health <= 0.0:
		die()

func die() -> void:
	_damage_bar.hide_bar()
	var pickup_instance := asteroid_pickup.instantiate()
	var items_scene: Node = $"../../../Items"
	items_scene.add_child(pickup_instance)
	pickup_instance.global_position = global_transform.origin
	pickup_instance.resource = gained_resource
	call_deferred("queue_free")
