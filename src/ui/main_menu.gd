extends CanvasLayer

@export var start_scene: PackedScene

# main menu
@onready var start_button: Button = $Control/MarginContainer/VBoxContainer/VBoxContainer/Start
@onready var new_game: Button = $Control/MarginContainer/VBoxContainer/VBoxContainer/NewGame
@onready var quit_button: Button = $Control/MarginContainer/VBoxContainer/VBoxContainer/Quit
@onready var credits_button: Button = $Control/MarginContainer/VBoxContainer/VBoxContainer/Credits
@onready var settings_button: Button = $Control/MarginContainer/VBoxContainer/VBoxContainer/Settings
@onready var confirmation_dialog: ConfirmationDialog = $Control/MarginContainer/VBoxContainer/VBoxContainer/ConfirmationDialog
@onready var main_body_vbox: VBoxContainer = $Control/MarginContainer/VBoxContainer/VBoxContainer

# credits
@onready var credits_panel: MarginContainer = $Control/MarginContainer/VBoxContainer/CreditsPanel
@onready var credits_back_button: Button = $Control/MarginContainer/VBoxContainer/CreditsPanel/VBoxContainer/CreditsBackButton

# settings
@onready var settings_panel: MarginContainer = $Control/MarginContainer/VBoxContainer/SettingsPanel
@onready var settings_back_button: Button = $Control/MarginContainer/VBoxContainer/SettingsPanel/TabContainer/General/SettingsBackButton
@onready var fullscreen_option: OptionButton = $Control/MarginContainer/VBoxContainer/SettingsPanel/TabContainer/General/GridContainer/FullScreenOption
@onready var zoom_level_label: Label = $Control/MarginContainer/VBoxContainer/SettingsPanel/TabContainer/General/GridContainer/ZoomLevel
@onready var zoom_level_option: OptionButton = $Control/MarginContainer/VBoxContainer/SettingsPanel/TabContainer/General/GridContainer/ZoomLevelOption
@onready var vsync_option: OptionButton = $Control/MarginContainer/VBoxContainer/SettingsPanel/TabContainer/General/GridContainer/VSyncOption
@onready var volume_slider: HSlider = $Control/MarginContainer/VBoxContainer/SettingsPanel/TabContainer/General/GridContainer/VolumeControls/VolumeSlider
@onready var volume_value: Label = $Control/MarginContainer/VBoxContainer/SettingsPanel/TabContainer/General/GridContainer/VolumeControls/VolumeValue

func _ready() -> void:
	GameManager.game_state = Enums.GameState.MAIN_MENU
	start_button.pressed.connect(_on_start_pressed)
	new_game.pressed.connect(_on_new_game_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	confirmation_dialog.visibility_changed.connect(_style_confimation_dialogue)
	confirmation_dialog.confirmed.connect(_on_deletion_confirmed)

	# credits
	credits_button.pressed.connect(_on_credits_button_pressed)
	credits_back_button.pressed.connect(_on_close_credits_button_pressed)

	# settings
	settings_button.pressed.connect(_on_settings_button_pressed)
	settings_back_button.pressed.connect(_on_close_settings_button_pressed)
	fullscreen_option.item_selected.connect(_on_fullscreen_selected)
	zoom_level_option.item_selected.connect(_on_zoom_selected)
	vsync_option.item_selected.connect(_on_vsync_selected)
	volume_slider.value_changed.connect(_on_volume_changed)

	_sync_settings_ui()

	# Give defauls to every button in this main menu
	for child in get_tree().get_root().find_children("", "Button", true, false):
		if child is Button and !child.disabled:
			child.mouse_entered.connect(_on_button_hovered)
			child.pressed.connect(_on_button_clicked)

	if GameManager.has_savegame():
		start_button.text = "Continue"
	else:
		start_button.text = "Start"
		new_game.visible = false

func _sync_settings_ui() -> void:
	fullscreen_option.select(UserSettings.fullscreen_mode)
	zoom_level_option.select(UserSettings.zoom_index)
	vsync_option.select(UserSettings.vsync_mode)
	volume_slider.value = UserSettings.volume * 100.0
	_update_volume_label(volume_slider.value)
	_update_zoom_visibility()


func _update_zoom_visibility() -> void:
	var show_zoom := UserSettings.fullscreen_mode == UserSettings.FullscreenOption.WINDOWED
	zoom_level_label.visible = show_zoom
	zoom_level_option.visible = show_zoom

func _on_start_pressed() -> void:
	if GameManager.has_savegame():
		GameManager.load_game()
	else:
		GameManager.start_new_game()

func _on_new_game_pressed() -> void:
		# Ask for confirmation
		AudioPlayer.play_ui_error()
		confirmation_dialog.popup_centered()

func _on_deletion_confirmed() -> void:
	# Delete savegame
	var success = GameManager.delete_savegame()
	if success:
		start_button.text = "Start"
		new_game.visible = false
	else:
		print("Deleting the save game failed. How can this happen?")

func _on_quit_pressed() -> void:
	GameManager.quit_game()

func _style_confimation_dialogue() -> void:
	var ok_button :Button = confirmation_dialog.get_ok_button()
	var style_normal := StyleBoxFlat.new()
	style_normal.bg_color = Color("770000ff")
	ok_button.add_theme_stylebox_override("normal", style_normal)
	ok_button.add_theme_stylebox_override("hover", style_normal)
	ok_button.add_theme_stylebox_override("pressed", style_normal)

func _on_button_hovered() -> void:
	AudioPlayer.play_ui_button_hover()

func _on_button_clicked() -> void:
	AudioPlayer.play_ui_button_click()

# credits
func _on_credits_button_pressed() -> void:
	main_body_vbox.hide()
	credits_panel.show()

func _on_close_credits_button_pressed() -> void:
	credits_panel.hide()
	main_body_vbox.show()

# settings
func _on_settings_button_pressed() -> void:
	main_body_vbox.hide()
	settings_panel.show()
	_sync_settings_ui()

func _on_close_settings_button_pressed() -> void:
	settings_panel.hide()
	main_body_vbox.show()


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
