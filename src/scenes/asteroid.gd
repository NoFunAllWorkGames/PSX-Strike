extends RigidBody3D
class_name Asteroid

# No defaults, this is currently only set in
# spawn_gaussian_cloud
@export var max_health: float
@export var health: float
@export var gained_resource: int
@export var mesh_seed: int = -1
@export var mesh_radius: float = 1.0
@export var is_precious: bool = false
@export var hull_contact_area: Area3D

const ProceduralAsteroidMeshBuilder := preload("res://src/utils/procedural_asteroid_mesh.gd")
var asteroid_pickup = preload("res://scenes/Objects/asteroid_pickup.tscn")

@onready var _hit_effect = $hit_particles
@onready var _mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _damage_bar = $DamageBar


func _ready() -> void:

	if mesh_seed < 0:
		mesh_seed = randi()
	_apply_procedural_mesh()
	hull_contact_area.body_entered.connect(_on_hull_contact_play_sound)


func _exit_tree() -> void:
	hull_contact_area.body_entered.disconnect(_on_hull_contact_play_sound)


func _on_hull_contact_play_sound(body: Node3D) -> void:
	if body != GameManager.PlayerShip:
		return

	AudioPlayer.play_asteroid_collision()


func _apply_procedural_mesh() -> void:
	var mesh: ArrayMesh = ProceduralAsteroidMeshBuilder.build(mesh_seed, mesh_radius)
	_mesh_instance.mesh = mesh

func take_damage(applied_damage: float) -> void:
	health -= applied_damage
	_damage_bar.show_health()
	_hit_effect.play()
	if health <= 0.0:
		die()

func die() -> void:
	_damage_bar.hide_bar()
	var pickup_instance := asteroid_pickup.instantiate()
	pickup_instance.resource = gained_resource
	pickup_instance.is_precious = is_precious
	var items_scene: Node = $"../../../Items"
	items_scene.add_child(pickup_instance)
	pickup_instance.global_position = global_transform.origin
	AudioPlayer.play_asteroid_blast()
	call_deferred("queue_free")
