extends MarginContainer

signal closed

@onready var settings_tabs: TabContainer = $TabContainer
@onready var settings_back_button: Button = $TabContainer/General/SettingsBackButton
@onready var fullscreen_option: OptionButton = $TabContainer/General/GridContainer/FullScreenOption
@onready var zoom_level_label: Label = $TabContainer/General/GridContainer/ZoomLevel
@onready var zoom_level_option: OptionButton = $TabContainer/General/GridContainer/ZoomLevelOption
@onready var vsync_option: OptionButton = $TabContainer/General/GridContainer/VSyncOption
@onready var volume_slider: HSlider = $TabContainer/General/GridContainer/VolumeControls/VolumeSlider
@onready var volume_value: Label = $TabContainer/General/GridContainer/VolumeControls/VolumeValue
@onready var keyboard_settings: ControlsSettings = $TabContainer/Keyboard
@onready var keyboard_back_button: Button = $TabContainer/Keyboard/ControlsBackButton


func _ready() -> void:
	settings_back_button.pressed.connect(_on_close_pressed)
	keyboard_back_button.pressed.connect(_on_close_pressed)
	fullscreen_option.item_selected.connect(_on_fullscreen_selected)
	zoom_level_option.item_selected.connect(_on_zoom_selected)
	vsync_option.item_selected.connect(_on_vsync_selected)
	volume_slider.value_changed.connect(_on_volume_changed)
	_configure_option_button_font(fullscreen_option)
	_configure_option_button_font(zoom_level_option)
	_configure_option_button_font(vsync_option)

	for button in [settings_back_button, keyboard_back_button]:
		button.mouse_entered.connect(_on_button_hovered)
		button.pressed.connect(_on_button_clicked)

	sync_ui()


func open() -> void:
	show()
	sync_ui()


func close() -> void:
	hide()
	keyboard_settings.cancel_listening()


func sync_ui() -> void:
	fullscreen_option.select(UserSettings.fullscreen_mode)
	zoom_level_option.select(UserSettings.zoom_index)
	vsync_option.select(UserSettings.vsync_mode)
	volume_slider.value = UserSettings.volume * 100.0
	_update_volume_label(volume_slider.value)
	_update_zoom_visibility()


func _on_close_pressed() -> void:
	close()
	closed.emit()


func _on_fullscreen_selected(index: int) -> void:
	UserSettings.set_fullscreen_mode(index)
	_update_zoom_visibility()


func _on_zoom_selected(index: int) -> void:
	UserSettings.set_zoom_index(index)


func _on_vsync_selected(index: int) -> void:
	UserSettings.set_vsync_mode(index)


func _on_volume_changed(value: float) -> void:
	_update_volume_label(value)
	UserSettings.set_volume(value / 100.0)


func _update_volume_label(value: float) -> void:
	volume_value.text = "%d%%" % roundi(value)


func _update_zoom_visibility() -> void:
	var show_zoom := UserSettings.fullscreen_mode == UserSettings.FullscreenOption.WINDOWED
	zoom_level_label.visible = show_zoom
	zoom_level_option.visible = show_zoom


func _configure_option_button_font(option: OptionButton) -> void:
	option.add_theme_font_size_override("font_size", 8)
	option.get_popup().add_theme_font_size_override("font_size", 8)


func _on_button_hovered() -> void:
	AudioPlayer.play_ui_button_hover()


func _on_button_clicked() -> void:
	AudioPlayer.play_ui_button_click()
