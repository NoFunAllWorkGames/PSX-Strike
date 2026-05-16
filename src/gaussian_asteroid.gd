@tool
extends Area3D

@export_tool_button("Create Asteroids", "CreateIcon") var create_button = create_asteroids
@export_tool_button("Clear Asteroids", "ClearIcon") var clear_button = clear_asteroids
@export_group("Field Settings")
@export var count: int = 100
@export var spread: float = 50.0 # Replaces noise_strength

@export_group("Asteroid Settings")
@export var max_health: float = 100.0
@export var health: float = 100.0

const asteroid_scene := preload("res://scenes/asteroid.tscn")

func _ready() -> void:
	if not Engine.is_editor_hint():
		SignalBus.damage_asteroid.connect(_on_damage_asteroid)

func _on_damage_asteroid(target, damage) -> void:
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(damage)

func create_asteroids() -> void:
	clear_asteroids()
	spawn_gaussian_cloud()

func clear_asteroids() -> void:
	for child in get_children():
		child.free()

func spawn_gaussian_cloud() -> void:

	for i in range(count):
		var direction = Vector3(
			randfn(0, 1),
			randfn(0, 1),
			randfn(0, 1)
		).normalized()
		
		var distance = randfn(0, spread)
		var final_pos = direction * distance
				
		# Add Data
		health = 50.0
		# First number is random cap, second number is always added
		var gained_resource :float = randi() % 10 + 1

		var asteroid_instance = asteroid_scene.instantiate()
		asteroid_instance.transform.origin = final_pos
		asteroid_instance.health = health
		asteroid_instance.max_health = health
		asteroid_instance.gained_resource = gained_resource
		add_child(asteroid_instance)

		if Engine.is_editor_hint():
			var root = get_tree().edited_scene_root
			asteroid_instance.owner = root
