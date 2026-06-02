class_name SpaceWorldPersistence

const SavedTheEntityStateResource := preload("res://src/data/saved_the_entity_state.gd")
const SavedHaulerStateResource := preload("res://src/data/saved_hauler_state.gd")
const SavedAsteroidStateResource := preload("res://src/data/saved_asteroid_state.gd")
const SpaceWorldStateResource := preload("res://src/data/space_world_state.gd")

const SPACE_SCENE_PATH := "res://scenes/Level/Space.tscn"
const STATION_SCENE_PATH := "res://scenes/Level/Station.tscn"
const WORLD_ENEMIES_PATH := "HBoxContainer/SubViewportContainer/SubViewport/World/Enemies"
const NOISE_ASTEROID_PATH := "HBoxContainer/SubViewportContainer/SubViewport/World/Environment/NoiseAsteroid"
const ENEMY_SPAWNER_PATH := "Managers/EnemySpawner"
const THE_ENTITY_PATH := WORLD_ENEMIES_PATH + "/TheEntity"
const HAULER_SCENE := preload("res://scenes/Ships/enemy_ship_hauler.tscn")
const ASTEROID_SCENE := preload("res://scenes/Objects/asteroid.tscn")


static func capture_from_scene(space_root: Node) -> SpaceWorldStateResource:
	var state := SpaceWorldStateResource.new()

	var the_entity: Node = space_root.get_node_or_null(THE_ENTITY_PATH)
	if the_entity != null and the_entity.has_method("capture_state"):
		state.the_entity = the_entity.capture_state()

	var enemies_parent: Node = space_root.get_node_or_null(WORLD_ENEMIES_PATH)
	if enemies_parent != null:
		for child in enemies_parent.get_children():
			if _is_hauler(child):
				state.haulers.append(_capture_hauler(child))

	var noise_asteroid: Node = space_root.get_node_or_null(NOISE_ASTEROID_PATH)
	if noise_asteroid != null:
		for child in noise_asteroid.get_children():
			if child is Asteroid:
				state.asteroids.append(_capture_asteroid(child))

	var spawner: Node = space_root.get_node_or_null(ENEMY_SPAWNER_PATH)
	if spawner != null and "spawn_counter" in spawner:
		state.enemy_spawn_counter = spawner.spawn_counter

	return state


static func restore_to_scene(space_root: Node, state: SpaceWorldStateResource) -> void:
	if state == null:
		return

	var the_entity: Node = space_root.get_node_or_null(THE_ENTITY_PATH)
	if the_entity != null and state.the_entity != null and the_entity.has_method("apply_saved_state"):
		the_entity.apply_saved_state(state.the_entity)

	var enemies_parent: Node = space_root.get_node_or_null(WORLD_ENEMIES_PATH)
	if enemies_parent != null:
		for child in enemies_parent.get_children():
			if _is_hauler(child):
				child.free()

		for hauler_state in state.haulers:
			_restore_hauler(enemies_parent, hauler_state)

	var noise_asteroid: Node = space_root.get_node_or_null(NOISE_ASTEROID_PATH)
	if noise_asteroid != null:
		for child in noise_asteroid.get_children():
			child.free()

		for asteroid_state in state.asteroids:
			_restore_asteroid(noise_asteroid, asteroid_state)

	var spawner: Node = space_root.get_node_or_null(ENEMY_SPAWNER_PATH)
	if spawner != null and "spawn_counter" in spawner:
		spawner.spawn_counter = state.enemy_spawn_counter


static func _is_hauler(node: Node) -> bool:
	return node is RigidBody3D and "enemy_ship_data" in node


static func _capture_hauler(hauler: RigidBody3D) -> SavedHaulerStateResource:
	var hauler_state := SavedHaulerStateResource.new()
	hauler_state.node_name = hauler.name
	hauler_state.transform = hauler.global_transform
	hauler_state.linear_velocity = hauler.linear_velocity
	hauler_state.enemy_ship_data = hauler.enemy_ship_data.duplicate(true) as EnemyShipData
	return hauler_state


static func _capture_asteroid(asteroid: Asteroid) -> SavedAsteroidStateResource:
	var asteroid_state := SavedAsteroidStateResource.new()
	asteroid_state.position = asteroid.global_position
	asteroid_state.health = asteroid.health
	asteroid_state.max_health = asteroid.max_health
	asteroid_state.gained_resource = asteroid.gained_resource
	return asteroid_state


static func _restore_hauler(enemies_parent: Node, hauler_state: SavedHaulerStateResource) -> void:
	var hauler := HAULER_SCENE.instantiate() as RigidBody3D
	hauler.name = hauler_state.node_name
	hauler.enemy_ship_data = hauler_state.enemy_ship_data.duplicate(true) as EnemyShipData
	enemies_parent.add_child(hauler)
	hauler.global_transform = hauler_state.transform
	hauler.linear_velocity = hauler_state.linear_velocity


static func _restore_asteroid(noise_asteroid: Node, asteroid_state: SavedAsteroidStateResource) -> void:
	var asteroid := ASTEROID_SCENE.instantiate() as Asteroid
	asteroid.transform.origin = asteroid_state.position
	asteroid.health = asteroid_state.health
	asteroid.max_health = asteroid_state.max_health
	asteroid.gained_resource = asteroid_state.gained_resource
	noise_asteroid.add_child(asteroid)
	asteroid.add_to_group("Asteroid")
