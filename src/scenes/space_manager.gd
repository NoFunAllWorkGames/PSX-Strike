extends Node

func _ready() -> void:

	# Initialize GameManager.PlayerShip
	# Instantiating make overwrites an already existing ship
	# on the other hand the level is the one that creates the ship
	const Player_Parent_Node := NodePath("HBoxContainer/SubViewportContainer/SubViewport/World/Characters")
	var player_parent_node: Node = get_node(Player_Parent_Node)

	# Always clean-instantiate the template node base first inside the new scene tree context
	const PLAYER_SHIP_ARCHON = preload("res://scenes/Ships/PlayerShip_Archon.tscn")
	GameManager.PlayerShip = PLAYER_SHIP_ARCHON.instantiate() as CharacterBody3D
	GameManager.PlayerShip.name = GameManager.PLAYER_SHIP_NODE_NAME

	if GameManager.game_state == Enums.GameState.NEW_GAME:
		# Standard default spawn placement logic
		GameManager.PlayerShip.position = Vector3(0.0, 0.0, 8.0)
		GameManager.PlayerShip.rotation_degrees = Vector3(0.0, -180.0, 0.0)

	elif GameManager.game_state == Enums.GameState.LOADED:
		# Manually apply the precise saved coordinates stored in GameManager 
		# AFTER instantiation overrides them with defaults
		pass
	else:
		# The same, just be fixed
		GameManager.PlayerShip.transform = GameManager.saved_player_transform
	
	# Attach the configured node instance to the active tree hierarchy
	player_parent_node.add_child(GameManager.PlayerShip)

	var regular_undock: bool = GameManager.previous_scene_path == "res://scenes/Level/Station.tscn" and GameManager.game_state != Enums.GameState.LOADED
	if regular_undock:
		undock_ship()
		
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
