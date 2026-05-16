extends Node

var PlayerShip
var _player_in_dock_zone: bool = false

func _ready() -> void:
	GameManager.PlayerShip = $"../../Characters/PlayerShipArchon" as CharacterBody3D
	PlayerShip = GameManager.PlayerShip
	var area_3d: Area3D = get_node("Hull/Area3D")
	area_3d.body_entered.connect(_on_area_3d_body_entered)
	area_3d.body_exited.connect(_on_area_3d_body_exited)
	InputManager.interact_pressed.connect(_on_interact_pressed)
	undock_ship()

func _exit_tree() -> void:
	InputManager.interact_pressed.disconnect(_on_interact_pressed)

func _on_interact_pressed() -> void:
	if not _player_in_dock_zone:
		return
	GameManager.transition_to("res://scenes/Level/Station.tscn")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body != PlayerShip:
		return
	_player_in_dock_zone = true
	SignalBus.display_action_label.emit("Press G to enter")
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body != PlayerShip:
		return
	_player_in_dock_zone = false
	SignalBus.display_action_label.emit("")

func undock_ship():
	print("Undocking ship")
	# Start from Main Menu
	# This code is deactivated because I don't know why I wanted to
	# set the position when the player starts the game.
	# It should be easier to use the pre-set position
	#if GameManager.previous_scene_path == "res://scenes/Level/Main_Menu.tscn":
		#print("Undocking ship from main menu")
		#var spawn_position := $SpawnUndockStation.global_position as Vector3
		#var spawn_position_direction := $SpawnUndockStation.global_rotation as Vector3
		#PlayerShip.global_position = spawn_position
		#PlayerShip.global_rotation = spawn_position_direction

	# Start from Station
	if GameManager.previous_scene_path == "res://scenes/Level/Station.tscn":
		print("Undocking ship from station")
		var spawn_position = $SpawnUndockStation.global_position as Vector3
		var marker_basis = $SpawnUndockStation.global_transform.basis
		var opposite_direction = marker_basis.z.normalized()
		# Look in the opposite direction of the marker (set forward -z to +z of marker)
		PlayerShip.global_position = spawn_position
		PlayerShip.look_at(spawn_position + opposite_direction, Vector3.UP)

		# Give it an initial push out
		var direction: Vector3 = -PlayerShip.global_transform.basis.z
		PlayerShip.velocity += direction * 10
