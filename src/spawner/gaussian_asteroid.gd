extends Area3D

@export_group("Field Settings")
@export var count: int = 200
@export var spread: float = 200.0

@export_group("Asteroid Settings")
@export var max_health: float = 100.0
@export var health: float = 50.0

const asteroid_scene := preload("res://scenes/Objects/asteroid.tscn")

func _ready() -> void:
	SignalBus.damage_asteroid.connect(_on_damage_asteroid)
	if GameManager.should_restore_space_world():
		return
	spawn_gaussian_cloud()

func _on_damage_asteroid(target, damage) -> void:
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(damage)

func spawn_gaussian_cloud() -> void:
	for i in range(count):
		var direction = Vector3(
			randfn(0, 1),
			randfn(0, 1),
			randfn(0, 1)
		).normalized()

		var distance = randfn(0, spread)
		var final_pos = direction * distance
		var gained_resource :float = randi() % 10 + 1

		var asteroid_instance = asteroid_scene.instantiate()
		asteroid_instance.transform.origin = final_pos
		asteroid_instance.health = health
		asteroid_instance.max_health = max_health
		asteroid_instance.gained_resource = gained_resource
		add_child(asteroid_instance)
		asteroid_instance.add_to_group("Asteroid")
