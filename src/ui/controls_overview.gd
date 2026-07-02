extends CanvasLayer

const ROWS: Array[Dictionary] = [
	{"label": "Forward", "action": UserSettings.SHIP_FORWARD_ACTION},
	{"label": "Backward", "action": UserSettings.SHIP_BACK_ACTION},
	{"label": "Strafe left", "action": UserSettings.SHIP_STRAFE_LEFT_ACTION},
	{"label": "Strafe right", "action": UserSettings.SHIP_STRAFE_RIGHT_ACTION},
	{"label": "Ascend", "action": UserSettings.SHIP_ASCEND_ACTION},
	{"label": "Descend", "action": UserSettings.SHIP_DESCEND_ACTION},
	{"label": "Mining laser", "action": UserSettings.SHOOT_ACTION},
	{"label": "Enter station", "action": UserSettings.INTERACT_ACTION},
	{"label": "Look around", "binding": "Mouse"},
	{"label": "Menu", "action": "tab_menu"},
]

@onready var grid: GridContainer = $Overlay/CenterContainer/ControlsPanel/VBoxContainer/CenterContainer/GridContainer


func _ready() -> void:
	_populate_grid()


func _populate_grid() -> void:
	for row in ROWS:
		var name_label := Label.new()
		name_label.text = row["label"]
		name_label.add_theme_font_size_override("font_size", 8)
		grid.add_child(name_label)

		var binding_label := Label.new()
		if row.has("binding"):
			binding_label.text = row["binding"]
		else:
			binding_label.text = UserSettings.get_binding_label(row["action"])
		binding_label.add_theme_font_size_override("font_size", 8)
		binding_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		grid.add_child(binding_label)


func _input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return

	if (
		event is InputEventKey
		or event is InputEventMouseButton
		or event is InputEventJoypadButton
	):
		GameManager.close_controls_overview()
		get_viewport().set_input_as_handled()
