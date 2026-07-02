extends Node

signal interact_pressed
signal mouse_look_relative(relative: Vector2)

var enable_freelook_click_capture: bool = false

const _DOUBLE_ESC_MS: int = 400
var _last_escape_ms: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	_handle_tab_menu(event)
	_handle_escape(event)


func _unhandled_input(event: InputEvent) -> void:
	_handle_scene_input(event)


func _handle_escape(event: InputEvent) -> bool:
	if not (event is InputEventKey):
		return false
	if not event.pressed or event.echo:
		return false
	if event.keycode != KEY_ESCAPE:
		return false

	if GameManager.controls_overview_open:
		GameManager.close_controls_overview()
		get_viewport().set_input_as_handled()
		return true

	var now := Time.get_ticks_msec()
	if now - _last_escape_ms <= _DOUBLE_ESC_MS:
		GameManager.quit_game()
		get_viewport().set_input_as_handled()
		return true
	_last_escape_ms = now

	get_viewport().set_input_as_handled()
	return true


func _handle_tab_menu(event: InputEvent) -> bool:
	if GameManager.controls_overview_open:
		return false

	if not event.is_action_pressed("tab_menu"):
		return false

	if GameManager.player_is_dead:
		get_viewport().set_input_as_handled()
		return true

	match GameManager.game_state:
		Enums.GameState.SPACE, Enums.GameState.STATION, Enums.GameState.LOADED, Enums.GameState.NEW_GAME:
			GameManager.open_pause_overlay()
		Enums.GameState.PAUSED:
			GameManager.close_pause_overlay()
		Enums.GameState.MAIN_MENU:
			pass

	get_viewport().set_input_as_handled()
	return true


func _handle_scene_input(event: InputEvent) -> void:
	if GameManager.controls_overview_open:
		return
	if GameManager.player_is_dead:
		return
	if GameManager.game_state == Enums.GameState.PAUSED:
		return

	match GameManager.game_state:
		Enums.GameState.SPACE, Enums.GameState.LOADED, Enums.GameState.NEW_GAME:
			_handle_space_input(event)
		Enums.GameState.STATION, Enums.GameState.MAIN_MENU:
			pass


func _handle_space_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("interact"):
		interact_pressed.emit()
	elif event.is_action_pressed("Shoot"):
		SignalBus.shoot_action_pressed.emit()
	elif event.is_action_released("Shoot"):
		SignalBus.shoot_action_released.emit()
	elif event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_look_relative.emit(event.relative)
	elif enable_freelook_click_capture and event is InputEventMouseButton and event.pressed:
		capture_mouse()


func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func get_ship_forward_axis() -> float:
	return Input.get_action_strength("ship_forward") - Input.get_action_strength("ship_back")


func get_ship_strafe_axis() -> float:
	return Input.get_action_strength("ship_strafe_right") - Input.get_action_strength("ship_strafe_left")


func get_ship_vertical_axis() -> float:
	return Input.get_action_strength("ship_ascend") - Input.get_action_strength("ship_descend")
