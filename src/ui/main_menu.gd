extends CanvasLayer

@export var start_scene: PackedScene

@onready var start_button: Button = $Control/MarginContainer/VBoxContainer/VBoxContainer/Start
@onready var new_game: Button = $Control/MarginContainer/VBoxContainer/VBoxContainer/NewGame
@onready var quit_button: Button = $Control/MarginContainer/VBoxContainer/VBoxContainer/Quit
@onready var confirmation_dialog: ConfirmationDialog = $Control/MarginContainer/VBoxContainer/VBoxContainer/ConfirmationDialog

func _ready() -> void:
	GameManager.game_state = Enums.GameState.MAIN_MENU
	start_button.pressed.connect(_on_start_pressed)
	new_game.pressed.connect(_on_new_game_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	confirmation_dialog.visibility_changed.connect(_style_confimation_dialogue)
	confirmation_dialog.confirmed.connect(_on_deletion_confirmed)
		
	if GameManager.has_savegame():
		start_button.text = "Continue"
	else:
		start_button.text = "Start"
		new_game.visible = false

func _on_start_pressed() -> void:
	if GameManager.has_savegame():
		GameManager.load_game()
	else:
		GameManager.start_new_game()
		
func _on_new_game_pressed() -> void:
		# Ask for confirmation
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
