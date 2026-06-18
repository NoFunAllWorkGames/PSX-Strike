extends Area3D

@export_group("Field Settings")
@export var count: int = 50
@export var min_distance: float = 150.0
@export var spread: float = 600.0

@export_group("Asteroid Settings")
@export var max_health: float = 300.0
@export var health: float = 300.0

@export var asteroid_scene: PackedScene = preload("res://scenes/Objects/asteroid_precious.tscn")
@export var resource_range: int = 25

func _ready() -> void:
	SignalBus.damage_asteroid.connect(_on_damage_asteroid)

func _on_damage_asteroid(target, damage) -> void:
	target.take_damage(damage)

func spawn_gaussian_cloud() -> void:
	for i in range(count):
		var direction := Vector3(
			randfn(0, 1),
			randfn(0, 1),
			randfn(0, 1)
		).normalized()

		var distance: float = lerpf(min_distance, spread, randf())
		var final_pos: Vector3 = direction * distance
		var gained_resource: int = randi() % resource_range + 1

		var asteroid_instance = asteroid_scene.instantiate()
		asteroid_instance.transform.origin = final_pos
		asteroid_instance.rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)
		asteroid_instance.health = health
		asteroid_instance.max_health = max_health
		asteroid_instance.gained_resource = gained_resource
		asteroid_instance.mesh_seed = randi()
		add_child(asteroid_instance)
		asteroid_instance.add_to_group("Asteroid")
