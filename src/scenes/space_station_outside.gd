extends Node

var _player_in_dock_zone: bool = false

var hotkey_array = InputMap.action_get_events("interact")
var interact_hotkey = hotkey_array[0].as_text_physical_keycode()

@export var space_station_entry_area: Area3D

func _ready() -> void:
	space_station_entry_area.body_entered.connect(_on_area_3d_body_entered)
	space_station_entry_area.body_exited.connect(_on_area_3d_body_exited)
	InputManager.interact_pressed.connect(_on_interact_pressed)

func _exit_tree() -> void:
	InputManager.interact_pressed.disconnect(_on_interact_pressed)

func _on_interact_pressed() -> void:
	if not _player_in_dock_zone:
		return
	GameManager.transition_to("res://scenes/Level/Station.tscn")

func _on_area_3d_body_entered(_body: Node3D) -> void:
	_player_in_dock_zone = true
	SignalBus.display_action_label.emit("Press %s to enter" %interact_hotkey )

func _on_area_3d_body_exited(_body: Node3D) -> void:
	_player_in_dock_zone = false
	SignalBus.display_action_label.emit("")
