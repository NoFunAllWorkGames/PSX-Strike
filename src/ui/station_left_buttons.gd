extends Control

const RESET_ENTITY_COST := 10

@onready var reset_button: Button = $MarginContainer/VBoxContainer/Reset
@onready var undock_button: Button = $MarginContainer/VBoxContainer/undock


func _ready() -> void:
	InputManager.release_mouse()
	reset_button.pressed.connect(_on_reset_pressed)
	undock_button.pressed.connect(_on_undock_pressed)
	SignalBus.right_column_updated.connect(_update_reset_button)
	_update_reset_button()


func _update_reset_button() -> void:
	reset_button.disabled = GameManager.station_resources.money_amount < RESET_ENTITY_COST


func _on_reset_pressed() -> void:
	if GameManager.station_resources.money_amount < RESET_ENTITY_COST:
		return
	GameManager.station_resources.money_amount -= RESET_ENTITY_COST
	GameManager.the_entity_pending_reset = true
	SignalBus.right_column_updated.emit()


func _on_undock_pressed() -> void:
	print("Undock button pressed")
	GameManager.transition_to("res://scenes/Level/Space.tscn")
