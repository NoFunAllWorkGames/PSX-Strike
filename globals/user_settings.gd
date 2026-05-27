extends Node

const SETTINGS_PATH := "user://settings.cfg"
const NATIVE_SIZE := Vector2i(426, 240)
const ZOOM_MULTIPLIERS := [1, 2, 4]

const SHIP_FORWARD_ACTION := "ship_forward"
const SHIP_BACK_ACTION := "ship_back"
const SHIP_STRAFE_LEFT_ACTION := "ship_strafe_left"
const SHIP_STRAFE_RIGHT_ACTION := "ship_strafe_right"
const SHIP_ASCEND_ACTION := "ship_ascend"
const SHIP_DESCEND_ACTION := "ship_descend"
const INTERACT_ACTION := "interact"
const SHOOT_ACTION := "Shoot"

const REMAP_ACTIONS := [
	SHIP_FORWARD_ACTION,
	SHIP_BACK_ACTION,
	SHIP_STRAFE_LEFT_ACTION,
	SHIP_STRAFE_RIGHT_ACTION,
	SHIP_ASCEND_ACTION,
	SHIP_DESCEND_ACTION,
	INTERACT_ACTION,
	SHOOT_ACTION,
]

enum FullscreenOption {
	FULLSCREEN,
	WINDOWED,
	BORDERLESS,
}

enum VSyncOption {
	DISABLED,
	ENABLED,
	ADAPTIVE,
}

var fullscreen_mode: FullscreenOption = FullscreenOption.BORDERLESS
var zoom_index: int = 2
var vsync_mode: VSyncOption = VSyncOption.ENABLED
var volume: float = 1.0


func _ready() -> void:
	load_settings()
	call_deferred("apply_all")


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return

	fullscreen_mode = config.get_value("display", "fullscreen_mode", fullscreen_mode) as FullscreenOption
	zoom_index = clampi(config.get_value("display", "zoom_index", zoom_index), 0, ZOOM_MULTIPLIERS.size() - 1)
	vsync_mode = config.get_value("display", "vsync_mode", vsync_mode) as VSyncOption
	volume = config.get_value("audio", "volume", config.get_value("audio", "master_volume", volume))
	_load_input_bindings(config)


func save_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("display", "fullscreen_mode", fullscreen_mode)
	config.set_value("display", "zoom_index", zoom_index)
	config.set_value("display", "vsync_mode", vsync_mode)
	config.set_value("audio", "volume", volume)
	config.save(SETTINGS_PATH)


func apply_all() -> void:
	apply_vsync()
	apply_fullscreen()
	apply_volume()


func apply_fullscreen() -> void:
	var window := get_tree().root as Window
	match fullscreen_mode:
		FullscreenOption.FULLSCREEN:
			window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		FullscreenOption.WINDOWED:
			window.mode = Window.MODE_WINDOWED
			apply_zoom()
		FullscreenOption.BORDERLESS:
			window.mode = Window.MODE_FULLSCREEN


func apply_zoom() -> void:
	if fullscreen_mode != FullscreenOption.WINDOWED:
		return
	get_tree().root.size = NATIVE_SIZE * ZOOM_MULTIPLIERS[zoom_index]


func apply_vsync() -> void:
	var modes := [
		DisplayServer.VSYNC_DISABLED,
		DisplayServer.VSYNC_ENABLED,
		DisplayServer.VSYNC_ADAPTIVE,
	]
	DisplayServer.window_set_vsync_mode(modes[vsync_mode])


func apply_volume() -> void:
	var bus_index := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(bus_index, volume)


func set_fullscreen_mode(mode: int) -> void:
	fullscreen_mode = mode as FullscreenOption
	apply_fullscreen()
	save_settings()


func set_zoom_index(index: int) -> void:
	zoom_index = clampi(index, 0, ZOOM_MULTIPLIERS.size() - 1)
	apply_zoom()
	save_settings()


func set_vsync_mode(mode: int) -> void:
	vsync_mode = mode as VSyncOption
	apply_vsync()
	save_settings()


func set_volume(value: float) -> void:
	volume = clampf(value, 0.0, 1.0)
	apply_volume()
	save_settings()


func set_input_binding(action: String, event: InputEvent) -> void:
	if not _has_remap_action(action):
		return

	var binding_event := _normalize_binding_event(event)
	if binding_event == null:
		return

	_apply_action_event(action, binding_event)

	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("input", action, _serialize_event(binding_event))
	config.save(SETTINGS_PATH)


func get_binding_label(action: String) -> String:
	var event := _get_action_event(action)
	if event == null:
		return "Unbound"
	return event.as_text()


func _get_action_event(action: String) -> InputEvent:
	if not InputMap.has_action(action):
		return null

	var events := InputMap.action_get_events(action)
	if events.is_empty():
		return null
	return events[0]


func _load_input_bindings(config: ConfigFile) -> void:
	if not config.has_section("input"):
		return

	for action in REMAP_ACTIONS:
		if not config.has_section_key("input", action):
			continue

		var event := _deserialize_event(config.get_value("input", action))
		if event != null:
			_apply_action_event(action, event)


func _apply_action_event(action: String, event: InputEvent) -> void:
	if not InputMap.has_action(action):
		return

	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)


func _has_remap_action(action: String) -> bool:
	return action in REMAP_ACTIONS


func _normalize_binding_event(event: InputEvent) -> InputEvent:
	if event is InputEventKey:
		var key_event := InputEventKey.new()
		key_event.physical_keycode = event.physical_keycode
		key_event.keycode = event.keycode
		key_event.pressed = true
		return key_event

	if event is InputEventMouseButton:
		var mouse_event := InputEventMouseButton.new()
		mouse_event.button_index = event.button_index
		mouse_event.pressed = true
		return mouse_event

	return null


func _serialize_event(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		return {
			"type": "key",
			"physical_keycode": event.physical_keycode,
			"keycode": event.keycode,
		}

	if event is InputEventMouseButton:
		return {
			"type": "mouse",
			"button_index": event.button_index,
		}

	return {}


func _deserialize_event(data: Variant) -> InputEvent:
	if typeof(data) != TYPE_DICTIONARY:
		return null

	match data.get("type"):
		"key":
			var event := InputEventKey.new()
			event.physical_keycode = data.get("physical_keycode", KEY_NONE)
			event.keycode = data.get("keycode", KEY_NONE)
			return event
		"mouse":
			var event := InputEventMouseButton.new()
			event.button_index = data.get("button_index", MOUSE_BUTTON_LEFT)
			return event

	return null
