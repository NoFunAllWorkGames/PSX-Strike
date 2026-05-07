extends Node

signal level_loaded(scene_path: String)
signal level_complete()
signal player_spawn_requested(position: Vector3)

var default_player_scene: PackedScene

var _active_spawn_position: Vector3 = Vector3.ZERO
var _active_spawn_set: bool = false
var _spawn_points: Array = []
var _current_scene_path: String = ""

var _is_loading: bool = false

func _ready() -> void:

	await get_tree().process_frame
	if get_tree().current_scene and _current_scene_path.is_empty():
		_current_scene_path = get_tree().current_scene.scene_file_path
		_spawn_player()

func load_scene(path: String) -> void:
	if _is_loading:
		return
	_is_loading = true
	_active_spawn_set = false
	_active_spawn_position = Vector3.ZERO

	await _do_load(path)
	_is_loading = false

# used after character death
func reload_current_scene() -> void:
	if _is_loading or _current_scene_path.is_empty():
		return
	_is_loading = true

	await _do_load(_current_scene_path)
	_is_loading = false

func get_spawn_position() -> Vector3:
	if _active_spawn_set:
		return _active_spawn_position
	if not _spawn_points.is_empty():
		var sp: Node = _spawn_points[0]
		if sp and is_instance_valid(sp):
			return sp.global_position
	return Vector3.ZERO

func _do_load(path: String) -> void:
	get_tree().change_scene_to_file(path)
	_current_scene_path = path
	_spawn_points.clear()

	await get_tree().process_frame

	level_loaded.emit(path)
	_spawn_player()

func _get_level_config() -> LevelConfig:
	return get_tree().get_first_node_in_group("level_config") as LevelConfig

func _spawn_player() -> void:
	var spawn_pos := get_spawn_position()
	GameManager.pending_entry_id = ""

	# 1. Persistent player already in the tree — just reposition
	var persistent := get_tree().get_first_node_in_group("persistent_player")
	if persistent:
		player_spawn_requested.emit(spawn_pos)
		return

	# 2. Determine which scene to instantiate:
	# LevelConfig override → global default.
	var config := _get_level_config()
	var scene_to_use: PackedScene = null
	if config and config.player_scene:
		scene_to_use = config.player_scene
	elif default_player_scene:
		scene_to_use = default_player_scene

	if scene_to_use:
		var player := scene_to_use.instantiate()
		get_tree().current_scene.add_child(player)

	# Always emit — Character nodes connect to this in _ready() for repositioning.
	player_spawn_requested.emit(spawn_pos)

func _on_character_died(character: Node) -> void:
		reload_current_scene()
