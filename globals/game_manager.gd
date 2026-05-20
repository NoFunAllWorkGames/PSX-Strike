extends Node

var previous_scene_path: String = ""
var current_scene_path: String = ""

# Central Data Storage
var game_state: Enums.GameState = Enums.GameState.MAIN_MENU

# Player Ship
var PlayerShip: CharacterBody3D
var saved_player_transform: Transform3D = Transform3D.IDENTITY
const PLAYER_SHIP_NODE_NAME := "PlayerShipArchon"
const PLAYER_SHIP_SCENE := preload("res://scenes/Ships/PlayerShip_Archon.tscn")

# Components
var cargo: CargoData = preload("res://src/data/cargo_res.tres") as CargoData
var station_resources: StationResourcesData = preload("res://src/data/station_resources_res.tres") as StationResourcesData
var weapon_system: WeaponData = preload("res://src/data/weapon_res.tres") as WeaponData

# Pause Menu
var _state_before_pause: Enums.GameState = Enums.GameState.MAIN_MENU
var _pause_menu_instance: Node

func _ready() -> void:
	# Unpauses the game
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Check if the game was just started or
	# if we are coming from a scene_transition

	# If the game just started from nowhere, don't do anything
	if game_state == Enums.GameState.MAIN_MENU and current_scene_path == "" and not PlayerShip:
		return
	if has_savegame():
		load_game()
	else:
		start_new_game()

#region Scene Transition
func start_new_game() -> void:
	print("Starting New Game")
	game_state = Enums.GameState.NEW_GAME

	# Initialize Cargo
	const CARGO_RESOURCE_FILE = preload("res://src/data/cargo_res.tres")
	cargo = CARGO_RESOURCE_FILE.duplicate(true)
	# Initialize Station Resource
	const STATION_RESOURCES_RESOURCE_FILE = preload("res://src/data/station_resources_res.tres")
	station_resources = STATION_RESOURCES_RESOURCE_FILE.duplicate(true)
	# Initialize Weapon System
	const WEAPON_SYSTEM_RESOURCE_FILE = preload("res://src/data/weapon_res.tres")
	weapon_system = WEAPON_SYSTEM_RESOURCE_FILE.duplicate(true)
	
	const PLAYER_SHIP_ARCHON = preload("res://scenes/Ships/PlayerShip_Archon.tscn")
	GameManager.PlayerShip = PLAYER_SHIP_ARCHON.instantiate() as CharacterBody3D
	PlayerShip.name = PLAYER_SHIP_NODE_NAME
	
	# Standard default spawn placement logic
	PlayerShip.position = Vector3(0.0, 0.0, 8.0)
	PlayerShip.rotation_degrees = Vector3(0.0, -180.0, 0.0)
	
	transition_to("res://scenes/Level/Space.tscn")

func transition_to(target_path: String) -> void:
	# set global scene variables
	previous_scene_path = get_tree().current_scene.scene_file_path
	current_scene_path = target_path
	
	print("Changing scene from: " + previous_scene_path)
	print("Changing scene to: " + target_path)

	if game_state != Enums.GameState.NEW_GAME and game_state != Enums.GameState.LOADED:
		_detach_player_ship.call_deferred()
	# Do the scene change when the game feels like being ready
	get_tree().change_scene_to_file.call_deferred(target_path)
	
func _set_gamestate_enum(path: String) -> void:
	match path:
			"res://scenes/Level/Main_Menu.tscn":
					game_state = Enums.GameState.MAIN_MENU
			"res://scenes/Level/Space.tscn":
					game_state = Enums.GameState.SPACE
			"res://scenes/Level/Station.tscn":
					game_state = Enums.GameState.STATION
			# Else case
			_:
					pass

# Don't destroy the player ship because
# we keep a global reference to it
func _detach_player_ship() -> void:
	if not is_instance_valid(PlayerShip):
		return
	var parent := PlayerShip.get_parent()
	if parent:
		parent.remove_child(PlayerShip)
#endregion

#region Pause Menu
func open_pause_overlay() -> void:
	if game_state == Enums.GameState.PAUSED:
			return
	if game_state == Enums.GameState.MAIN_MENU:
			return
	_state_before_pause = game_state
	game_state = Enums.GameState.PAUSED
	const PAUSE_MENU_SCENE := preload("res://scenes/UI/Pause_Menu.tscn")
	_pause_menu_instance = PAUSE_MENU_SCENE.instantiate()
	get_tree().root.add_child(_pause_menu_instance)
	get_tree().paused = true
	InputManager.release_mouse()

func close_pause_overlay() -> void:
	if game_state != Enums.GameState.PAUSED:
			return
	game_state = _state_before_pause
	_close_pause_overlay()

func _close_pause_overlay() -> void:
	if is_instance_valid(_pause_menu_instance):
			_pause_menu_instance.queue_free()
			_pause_menu_instance = null
	get_tree().paused = false
	match game_state:
		Enums.GameState.SPACE:
				InputManager.capture_mouse()
		Enums.GameState.STATION:
				InputManager.release_mouse()
		_:
			pass
#endregion

#region Save System
# Savegames
const SAVE_FILE_PATH = "user://saves/savegame.tres"

func save_game() -> void:
	# declare the master holding savegame data
	var master_save = SaveGameData.new()
	# Prepare manual save data
	
	# Prepare PlayerShip
	var ship_packed_scene = PackedScene.new()
	var pack_error = ship_packed_scene.pack(PlayerShip)
	
	if pack_error != OK:
		print("Failed to pack PlayerShip structure. Error: ", pack_error)
		return
	
	var manual_data: Dictionary = {
		scene = game_state,
		previous_scene = previous_scene_path,
		current_scene = current_scene_path,
		player_transform = PlayerShip.global_transform
	}

	# assigns what actually is saved
	# see SaveGameData_res.gd for more information
	master_save.player_ship_scene = ship_packed_scene
	master_save.manual_data = manual_data
	master_save.cargo_data = cargo
	master_save.station_resources_data = station_resources
	
	# do the actual saving
	var error = ResourceSaver.save(master_save, SAVE_FILE_PATH)
	if error == OK:
			print("Game saved successfully to: ", SAVE_FILE_PATH)
	else:
			print("Failed to save game. Error code: ", error)
			
func has_savegame() -> bool:
	# Check if savegame exists
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file discovered.")
		return false
	return true

func load_game() -> void:
	game_state = Enums.GameState.LOADED

	# declare the master holding savegame data
	var loaded_data: SaveGameData = ResourceLoader.load(SAVE_FILE_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)

	# actual data retrieval, loads what is saved
	# see SaveGameData_res.gd for more information
	GameManager.PlayerShip = loaded_data.player_ship_scene.instantiate() as CharacterBody3D
	PlayerShip.name = PLAYER_SHIP_NODE_NAME
	cargo = loaded_data.cargo_data
	station_resources = loaded_data.station_resources_data
	# temp manual data retrieval
	if loaded_data.manual_data:
		var manual_data: Dictionary = loaded_data.manual_data
		previous_scene_path = manual_data.previous_scene
		current_scene_path = manual_data.current_scene
		saved_player_transform = manual_data.player_transform

	_close_pause_overlay()
	
	# Because I had issues with this, in case it's missing from saved
	if not current_scene_path:
		transition_to("res://scenes/Level/Space.tscn")
	# default case
	else:
		transition_to(current_scene_path)
	
	# debugging
	print("Game loaded successfully. Cargo amount: ", cargo.cargo_amount)
	print("Game loaded successfully. Station resources: ", station_resources.resources_amount)
	
func delete_savegame() -> bool:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var error = DirAccess.remove_absolute(SAVE_FILE_PATH)
		if error == OK:
			return true
	return false
	
#endregion

func quit_game() -> void:
	get_tree().quit()
