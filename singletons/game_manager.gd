extends Node

var PlayerShip: CharacterBody3D
var previous_scene_path: String = ""

const _DOUBLE_ESC_MS: int = 400
var _last_escape_ms: int = 0

func _input(event: InputEvent) -> void:
	quick_close_game(event)

func transition_to(target_path: String) -> void:
	# Store the path of the scene currently being exited
	var current_scene = get_tree().current_scene
	previous_scene_path = current_scene.scene_file_path
	# Logging
	print("Changing scene from: " + previous_scene_path)
	print("Changing scene to: " + target_path)
	# Do the scene change
	var error = get_tree().change_scene_to_file(target_path)

func quick_close_game(event) -> void:
	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
		return
	if event.keycode != KEY_ESCAPE:
		return
	var now := Time.get_ticks_msec()
	if now - _last_escape_ms <= _DOUBLE_ESC_MS:
		get_tree().quit()
	_last_escape_ms = now
