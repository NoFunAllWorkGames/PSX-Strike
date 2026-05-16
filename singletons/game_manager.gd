extends Node

const PAUSE_MENU_SCENE := preload("res://scenes/UI/Pause_Menu.tscn")

var PlayerShip: CharacterBody3D
var previous_scene_path: String = ""

var game_state: Enums.GameState = Enums.GameState.MAIN_MENU

var _state_before_pause: Enums.GameState = Enums.GameState.MAIN_MENU
var _pause_menu_instance: Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_sync_state_from_current_scene")


func _sync_state_from_current_scene() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	_apply_state_from_scene_path(scene.scene_file_path)


func _apply_state_from_scene_path(path: String) -> void:
	match path:
		"res://scenes/Level/Main_Menu.tscn":
			game_state = Enums.GameState.MAIN_MENU
		"res://scenes/Level/Space.tscn":
			game_state = Enums.GameState.SPACE
		"res://scenes/Level/Station.tscn":
			game_state = Enums.GameState.STATION
		_:
			pass


func transition_to(target_path: String) -> void:
	var current_scene = get_tree().current_scene
	previous_scene_path = current_scene.scene_file_path
	print("Changing scene from: " + previous_scene_path)
	print("Changing scene to: " + target_path)
	var error = get_tree().change_scene_to_file(target_path)
	_apply_state_from_scene_path(target_path)


func open_pause_overlay() -> void:
	if game_state == Enums.GameState.PAUSED:
		return
	if game_state == Enums.GameState.MAIN_MENU:
		return
	_state_before_pause = game_state
	game_state = Enums.GameState.PAUSED
	_pause_menu_instance = PAUSE_MENU_SCENE.instantiate()
	get_tree().root.add_child(_pause_menu_instance)
	get_tree().paused = true
	InputManager.release_mouse()


func close_pause_overlay() -> void:
	if game_state != Enums.GameState.PAUSED:
		return
	game_state = _state_before_pause
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


func quit_game() -> void:
	get_tree().quit()
