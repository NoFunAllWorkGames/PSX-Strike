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
@onready var player_name_input: LineEdit = $Control/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/PlayerName
@onready var how_to_play_label: Label = $Control/howtoplay_Label

# credits
@onready var credits_panel: MarginContainer = $Control/MarginContainer/VBoxContainer/CreditsPanel
@onready var credits_back_button: Button = $Control/MarginContainer/VBoxContainer/CreditsPanel/VBoxContainer/CreditsBackButton

# settings
@onready var settings_panel: MarginContainer = $Control/MarginContainer/VBoxContainer/SettingsPanel


func _ready() -> void:
	$Soundtrack.play()
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
	settings_panel.closed.connect(_on_close_settings_button_pressed)

	_sync_player_name_ui()
	player_name_input.text_changed.connect(_on_player_name_changed)

	# Give defaults to every button in this main menu, except remapping buttons.
	for child in get_tree().get_root().find_children("", "Button", true, false):
		if child is Button and !child.disabled and not settings_panel.keyboard_settings.is_bind_button(child):
			child.mouse_entered.connect(_on_button_hovered)
			child.pressed.connect(_on_button_clicked)

	if GameManager.has_savegame():
		start_button.text = "Continue"
	else:
		start_button.text = "Start"
		new_game.visible = false

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
	how_to_play_label.hide()
	credits_panel.show()

func _on_close_credits_button_pressed() -> void:
	credits_panel.hide()
	how_to_play_label.show()
	main_body_vbox.show()

# settings
func _on_settings_button_pressed() -> void:
	main_body_vbox.hide()
	how_to_play_label.hide()
	settings_panel.open()

func _on_close_settings_button_pressed() -> void:
	settings_panel.close()
	how_to_play_label.show()
	main_body_vbox.show()
