extends CanvasLayer

@export var start_scene: PackedScene

const MAIN_BODY := "Control/MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer"
const MENU_COLUMN := "Control/MarginContainer/HBoxContainer/VBoxContainer"

# main menu
@onready var start_button: Button = get_node(MAIN_BODY + "/Start")
@onready var new_game: Button = get_node(MAIN_BODY + "/NewGame")
@onready var quit_button: Button = get_node(MAIN_BODY + "/Quit")
@onready var credits_button: Button = get_node(MAIN_BODY + "/Credits")
@onready var settings_button: Button = get_node(MAIN_BODY + "/Settings")
@onready var confirmation_dialog: ConfirmationDialog = get_node(MAIN_BODY + "/ConfirmationDialog")
@onready var main_body_vbox: VBoxContainer = get_node(MAIN_BODY)
@onready var player_name_input: LineEdit = get_node(MAIN_BODY + "/HBoxContainer/PlayerName")
@onready var how_to_play_label: Label = $Control/MarginContainer/HBoxContainer/VBoxContainer2/howtoplay_Label
@onready var separator2: HSeparator = get_node(MENU_COLUMN + "/HSeparator2")

# credits
@onready var credits_panel: MarginContainer = get_node(MENU_COLUMN + "/CreditsPanel")
@onready var credits_back_button: Button = get_node(MENU_COLUMN + "/CreditsPanel/VBoxContainer/CreditsBackButton")

# settings
@onready var settings_panel: MarginContainer = get_node(MENU_COLUMN + "/SettingsPanel")


func _ready() -> void:
	$Soundtrack.play()
	GameManager.game_state = Enums.GameState.MAIN_MENU
	start_button.pressed.connect(_on_start_pressed)
	new_game.pressed.connect(_on_new_game_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	confirmation_dialog.confirmed.connect(_on_deletion_confirmed)

	# credits
	credits_button.pressed.connect(_on_credits_button_pressed)
	credits_back_button.pressed.connect(_on_close_credits_button_pressed)

	# settings
	settings_button.pressed.connect(_on_settings_button_pressed)
	settings_panel.closed.connect(_on_close_settings_button_pressed)

	_sync_player_name_ui()
	player_name_input.text_changed.connect(_on_player_name_changed)

	# Give defaults to every button in this main menu, except remapping buttons.
	for child in get_tree().get_root().find_children("", "Button", true, false):
		if child is Button and !child.disabled and not settings_panel.keyboard_settings.is_bind_button(child):
			child.mouse_entered.connect(_on_button_hovered)
			child.pressed.connect(_on_button_clicked)

	_adjust_main_body_spacing()

func _adjust_main_body_spacing() -> void:
	if GameManager.has_savegame():
		start_button.text = "Continue"
		_existing_savegame_layout(true)
	else:
		start_button.text = "Start"
		new_game.visible = false
		_existing_savegame_layout(false)

func _existing_savegame_layout(continue_mode: bool) -> void:
	match continue_mode:
		true:
			separator2.add_theme_constant_override("separation", 24)
			main_body_vbox.add_theme_constant_override("separation", 0)
		false:
			separator2.add_theme_constant_override("separation", 30)
			main_body_vbox.add_theme_constant_override("separation", 4)

func _sync_player_name_ui() -> void:
	var display_name := UserSettings.player_name
	if display_name.is_empty():
		display_name = GameManager.name_manager()
		UserSettings.set_player_name(display_name)
	player_name_input.text = display_name


func _on_player_name_changed(new_text: String) -> void:
	UserSettings.set_player_name(new_text)


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
		_existing_savegame_layout(false)
	else:
		print("Deleting the save game failed. How can this happen?")

func _on_quit_pressed() -> void:
	GameManager.quit_game()

func _on_button_hovered() -> void:
	AudioPlayer.play_ui_button_hover()

func _on_button_clicked() -> void:
	AudioPlayer.play_ui_button_click()

# credits
func _on_credits_button_pressed() -> void:
	main_body_vbox.hide()
	how_to_play_label.hide()
	separator2.add_theme_constant_override("separation", 0)
	credits_panel.show()

func _on_close_credits_button_pressed() -> void:
	credits_panel.hide()
	how_to_play_label.show()
	_adjust_main_body_spacing()
	main_body_vbox.show()

# settings
func _on_settings_button_pressed() -> void:
	main_body_vbox.hide()
	how_to_play_label.hide()
	separator2.add_theme_constant_override("separation", 0)
	settings_panel.open()

func _on_close_settings_button_pressed() -> void:
	settings_panel.close()
	how_to_play_label.show()
	_adjust_main_body_spacing()
	main_body_vbox.show()
