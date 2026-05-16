extends RigidBody3D
class_name Asteroid

@onready var items_scene: Node = $"../../../Items"

# No defaults, this is currently only set in
# spawn_gaussian_cloud
@export var max_health: float
@export var health: float
@export var gained_resource: int

var asteroid_pickup = preload("res://scenes/asteroid_pickup.tscn")


func _ready() -> void:
	add_to_group("Asteroid")

func take_damage(applied_damage: float) -> void:
	health -= applied_damage
	SignalBus.display_asteroid_lifebar.emit(self)
	if health <= 0.0:
		die()

func die() -> void:
	SignalBus.clear_asteroid_lifebar.emit()
	var pickup_instance := asteroid_pickup.instantiate()
	items_scene.add_child(pickup_instance)
	pickup_instance.global_position = global_transform.origin
	pickup_instance.resource = gained_resource
	call_deferred("queue_free")
