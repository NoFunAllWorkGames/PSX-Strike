extends CanvasLayer

@onready var save: Button = $CenterContainer/MarginContainer/MenuContent/VBoxContainer/Save
@onready var v_box_container: VBoxContainer = $CenterContainer/MarginContainer/MenuContent/VBoxContainer
@onready var settings_panel: MarginContainer = $CenterContainer/SettingsPanel

func _ready() -> void:
	print("Open")
	AudioPlayer.play_pausemenu_open()

	settings_panel.closed.connect(_on_settings_closed)

	for button in v_box_container.get_children():
		if button is Button and !button.disabled:
			button.mouse_entered.connect(_on_button_hovered)
			button.pressed.connect(_on_button_clicked)

func _on_continue_pressed() -> void:
	GameManager.close_pause_overlay()

func _on_quit_pressed() -> void:
	GameManager.quit_game()

func _on_save_pressed() -> void:
	GameManager.save_game()
	save.text = "saved"
	save.disabled = true

func _on_load_pressed() -> void:
	GameManager.load_game()

func _on_settings_pressed() -> void:
	v_box_container.hide()
	settings_panel.open()

func _on_settings_closed() -> void:
	settings_panel.close()
	v_box_container.show()

func _on_tree_exiting() -> void:
	print("Close")
	AudioPlayer.play_pausemenu_close()

func _on_button_hovered() -> void:
	AudioPlayer.play_ui_button_hover()

func _on_button_clicked() -> void:
	AudioPlayer.play_ui_button_click()
