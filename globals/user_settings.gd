extends Node

const SETTINGS_PATH := "user://settings.cfg"
const NATIVE_SIZE := Vector2i(426, 240)
const ZOOM_MULTIPLIERS := [1, 2, 4]

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
var zoom_index: int = 4
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
	zoom_index = config.get_value("display", "zoom_index", zoom_index)
	vsync_mode = config.get_value("display", "vsync_mode", vsync_mode) as VSyncOption
	volume = config.get_value("audio", "volume", config.get_value("audio", "master_volume", volume))


func save_settings() -> void:
	var config := ConfigFile.new()
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
