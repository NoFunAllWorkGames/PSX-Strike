extends Node

func _ready() -> void:
	
	# Just for Space Scene debugging
	# Because I don't want to start the game from the main menu
	if not GameManager.game_state:
		GameManager.load_game()
		
	GameManager.game_state = Enums.GameState.SPACE

	# Initialize GameManager.PlayerShip
	if not is_instance_valid(GameManager.PlayerShip):
		GameManager.PlayerShip = GameManager.PLAYER_SHIP_SCENE.instantiate()

	# Instantiating make overwrites an already existing ship
	# on the other hand the level is the one that creates the ship
	const Player_Parent_Node := NodePath("HBoxContainer/SubViewportContainer/SubViewport/World/Characters")
	var player_parent_node: Node = get_node(Player_Parent_Node)


	# Attach the configured node instance to the active tree hierarchy
	player_parent_node.add_child(GameManager.PlayerShip)

	if GameManager.game_state in [Enums.GameState.LOADED, Enums.GameState.NEW_GAME]:
		GameManager.PlayerShip.transform = GameManager.saved_player_transform
	
	var regular_undock: bool = GameManager.previous_scene_path == "res://scenes/Level/Station.tscn" and GameManager.game_state != Enums.GameState.LOADED
	if regular_undock:
		undock_ship()
	else:
		GameManager.PlayerShip.global_transform = GameManager.saved_player_transform

	SignalBus.update_ui.emit()

func undock_ship():
	print("Undocking ship from station")
	# Set to the starting position and alignment
	var spawn_undock_station: Marker3D = $HBoxContainer/SubViewportContainer/SubViewport/World/Environment/SpaceStation/SpawnUndockStation
	var spawn_position = spawn_undock_station.global_position as Vector3
	var marker_basis = spawn_undock_station.global_transform.basis
	var opposite_direction = marker_basis.z.normalized()
	# Look in the opposite direction of the marker (set forward -z to +z of marker)
	GameManager.PlayerShip.global_position = spawn_position
	GameManager.PlayerShip.look_at(spawn_position + opposite_direction, Vector3.UP)

	# Give it an initial push out
	var direction: Vector3 = -GameManager.PlayerShip.global_transform.basis.z
	GameManager.PlayerShip.velocity += direction * 10
