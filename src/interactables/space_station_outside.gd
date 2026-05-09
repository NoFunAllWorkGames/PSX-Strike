extends Node

var PlayerShip

func _ready() -> void:
	GameManager.PlayerShip = $"../../Characters/PlayerShipArchon" as CharacterBody3D
	PlayerShip = GameManager.PlayerShip
	var area_3d: Area3D = get_node("Hull/Area3D")
	area_3d.body_entered.connect(_on_area_3d_body_entered)
	area_3d.body_exited.connect(_on_area_3d_body_exited)
	undock_ship()

func _on_area_3d_body_entered(body: Node3D) -> void:
	SignalBus.display_action_label.emit("Press G to enter")
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	SignalBus.display_action_label.emit("")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("interact"):
		GameManager.transition_to("res://scenes/Station.tscn")

func undock_ship():
	print("Undocking ship")
	# Start from Main Menu
	if GameManager.previous_scene_path == "res://scenes/Main_Menu.tscn":
		print("Undocking ship from main menu")
		var spawn_position := $SpawnUndockStation.global_position as Vector3
		var spawn_position_direction := $SpawnUndockStation.global_rotation as Vector3
		PlayerShip.global_position = spawn_position
		PlayerShip.global_rotation = spawn_position_direction

	# Start from Station
	if GameManager.previous_scene_path == "res://scenes/Station.tscn":
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