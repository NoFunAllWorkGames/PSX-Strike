class_name ControlsSettings
extends VBoxContainer

const SCROLL_STEP := 32

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var scroll_content: VBoxContainer = $ScrollContainer/ScrollContent
@onready var grid: GridContainer = $ScrollContainer/ScrollContent/CenterContainer/GridContainer
@onready var back_button: Button = $ControlsBackButton
@onready var forward_bind: Button = $ScrollContainer/ScrollContent/CenterContainer/GridContainer/ForwardBind
@onready var backward_bind: Button = $ScrollContainer/ScrollContent/CenterContainer/GridContainer/BackwardBind
@onready var strafe_left_bind: Button = $ScrollContainer/ScrollContent/CenterContainer/GridContainer/StrafeLeftBind
@onready var strafe_right_bind: Button = $ScrollContainer/ScrollContent/CenterContainer/GridContainer/StrafeRightBind
@onready var ascend_bind: Button = $ScrollContainer/ScrollContent/CenterContainer/GridContainer/AscendBind
@onready var descend_bind: Button = $ScrollContainer/ScrollContent/CenterContainer/GridContainer/DescendBind
@onready var shoot_bind: Button = $ScrollContainer/ScrollContent/CenterContainer/GridContainer/ShootBind
@onready var interact_bind: Button = $ScrollContainer/ScrollContent/CenterContainer/GridContainer/InteractBind

var _listening_action: String = ""
var _listening_button: Button = null


func _ready() -> void:
	scroll_container.gui_input.connect(_on_scroll_container_gui_input)
	back_button.mouse_entered.connect(_on_button_hovered)
	back_button.pressed.connect(_on_button_clicked)
	forward_bind.pressed.connect(_on_forward_bind_pressed)
	backward_bind.pressed.connect(_on_backward_bind_pressed)
	strafe_left_bind.pressed.connect(_on_strafe_left_bind_pressed)
	strafe_right_bind.pressed.connect(_on_strafe_right_bind_pressed)
	ascend_bind.pressed.connect(_on_ascend_bind_pressed)
	descend_bind.pressed.connect(_on_descend_bind_pressed)
	shoot_bind.pressed.connect(_on_shoot_bind_pressed)
	interact_bind.pressed.connect(_on_interact_bind_pressed)
	refresh()


func refresh() -> void:
	forward_bind.text = UserSettings.get_binding_label(UserSettings.SHIP_FORWARD_ACTION)
	backward_bind.text = UserSettings.get_binding_label(UserSettings.SHIP_BACK_ACTION)
	strafe_left_bind.text = UserSettings.get_binding_label(UserSettings.SHIP_STRAFE_LEFT_ACTION)
	strafe_right_bind.text = UserSettings.get_binding_label(UserSettings.SHIP_STRAFE_RIGHT_ACTION)
	ascend_bind.text = UserSettings.get_binding_label(UserSettings.SHIP_ASCEND_ACTION)
	descend_bind.text = UserSettings.get_binding_label(UserSettings.SHIP_DESCEND_ACTION)
	shoot_bind.text = UserSettings.get_binding_label(UserSettings.SHOOT_ACTION)
	interact_bind.text = UserSettings.get_binding_label(UserSettings.INTERACT_ACTION)
	_update_scroll_content_size()


func cancel_listening() -> void:
	if _listening_action.is_empty():
		return

	_listening_button.text = UserSettings.get_binding_label(_listening_action)
	_listening_action = ""
	_listening_button = null
	set_process_input(false)


func is_bind_button(button: Button) -> bool:
	return button in [
		forward_bind,
		backward_bind,
		strafe_left_bind,
		strafe_right_bind,
		ascend_bind,
		descend_bind,
		shoot_bind,
		interact_bind,
	]


func _update_scroll_content_size() -> void:
	scroll_content.custom_minimum_size = scroll_content.get_combined_minimum_size()


func _on_scroll_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				scroll_container.scroll_vertical = maxi(
					scroll_container.scroll_vertical - SCROLL_STEP,
					0,
				)
				scroll_container.accept_event()
			MOUSE_BUTTON_WHEEL_DOWN:
				scroll_container.scroll_vertical += SCROLL_STEP
				scroll_container.accept_event()


func _on_forward_bind_pressed() -> void:
	_start_listening(UserSettings.SHIP_FORWARD_ACTION, forward_bind)


func _on_backward_bind_pressed() -> void:
	_start_listening(UserSettings.SHIP_BACK_ACTION, backward_bind)


func _on_strafe_left_bind_pressed() -> void:
	_start_listening(UserSettings.SHIP_STRAFE_LEFT_ACTION, strafe_left_bind)


func _on_strafe_right_bind_pressed() -> void:
	_start_listening(UserSettings.SHIP_STRAFE_RIGHT_ACTION, strafe_right_bind)


func _on_ascend_bind_pressed() -> void:
	_start_listening(UserSettings.SHIP_ASCEND_ACTION, ascend_bind)


func _on_descend_bind_pressed() -> void:
	_start_listening(UserSettings.SHIP_DESCEND_ACTION, descend_bind)


func _on_shoot_bind_pressed() -> void:
	_start_listening(UserSettings.SHOOT_ACTION, shoot_bind)


func _on_interact_bind_pressed() -> void:
	_start_listening(UserSettings.INTERACT_ACTION, interact_bind)


func _start_listening(action: String, button: Button) -> void:
	if not _listening_action.is_empty():
		return

	_listening_action = action
	_listening_button = button
	button.text = "Press key..."
	set_process_input(true)


func _input(event: InputEvent) -> void:
	if _listening_action.is_empty():
		return

	if not event.is_pressed() or event.is_echo():
		return

	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		cancel_listening()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventKey or event is InputEventMouseButton:
		UserSettings.set_input_binding(_listening_action, event)
		_listening_button.text = UserSettings.get_binding_label(_listening_action)
		_listening_action = ""
		_listening_button = null
		set_process_input(false)
		get_viewport().set_input_as_handled()


func _on_button_hovered() -> void:
	AudioPlayer.play_ui_button_hover()


func _on_button_clicked() -> void:
	AudioPlayer.play_ui_button_click()
