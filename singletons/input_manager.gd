extends Node

signal interact_pressed
signal mouse_look_relative(relative: Vector2)

const _DOUBLE_ESC_MS: int = 400

var enable_freelook_click_capture: bool = false

var _last_escape_ms: int = 0


func _input(event: InputEvent) -> void:
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


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("interact"):
		interact_pressed.emit()
	elif event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_look_relative.emit(event.relative)
	elif enable_freelook_click_capture and event is InputEventMouseButton and event.pressed:
		capture_mouse()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		release_mouse()


func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func get_ship_yaw_axis() -> float:
	return Input.get_action_strength("ship_yaw_left") - Input.get_action_strength("ship_yaw_right")


func get_ship_pitch_axis() -> float:
	return Input.get_action_strength("ship_pitch_up") - Input.get_action_strength("ship_pitch_down")


func get_ship_forward_axis() -> float:
	return Input.get_action_strength("ship_forward") - Input.get_action_strength("ship_back")


func get_ship_strafe_axis() -> float:
	return Input.get_action_strength("ship_strafe_right") - Input.get_action_strength("ship_strafe_left")


func get_ship_vertical_axis() -> float:
	return Input.get_action_strength("ship_ascend") - Input.get_action_strength("ship_descend")
