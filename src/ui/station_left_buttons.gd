extends Control

const RESET_ENTITY_COST := 100

@onready var reset_button: Button = $MarginContainer/VBoxContainer/Reset
@onready var heal_button: Button = $MarginContainer/VBoxContainer/Heal
@onready var undock_button: Button = $MarginContainer/VBoxContainer/undock


func _ready() -> void:
	InputManager.release_mouse()
	reset_button.pressed.connect(_on_reset_pressed)
	heal_button.pressed.connect(_on_heal_pressed)
	undock_button.pressed.connect(_on_undock_pressed)
	SignalBus.right_column_updated.connect(_update_buttons)
	_update_buttons()


func _update_buttons() -> void:
	reset_button.disabled = GameManager.station_resources.money_amount < RESET_ENTITY_COST
	heal_button.disabled = not _can_heal()


func _can_heal() -> bool:
	if GameManager.station_resources.money_amount <= 0:
		return false
	var player := GameManager.PlayerShip
	if not is_instance_valid(player):
		return false
	return player.lifepoints < player.max_lifepoints


func _on_reset_pressed() -> void:
	if GameManager.station_resources.money_amount < RESET_ENTITY_COST:
		return
	GameManager.station_resources.money_amount -= RESET_ENTITY_COST
	GameManager.the_entity_pending_reset = true
	SignalBus.right_column_updated.emit()


func _on_heal_pressed() -> void:
	var player := GameManager.PlayerShip
	if not is_instance_valid(player):
		return
	var missing_hp: int = player.max_lifepoints - player.lifepoints
	if missing_hp <= 0:
		return
	var money := GameManager.station_resources.money_amount
	if money <= 0:
		return
	var heal_cost := mini(missing_hp, money)
	var healed: int = player.heal(heal_cost)
	if healed <= 0:
		return
	GameManager.station_resources.money_amount -= healed
	SignalBus.right_column_updated.emit()


func _on_undock_pressed() -> void:
	print("Undock button pressed")
	GameManager.transition_to("res://scenes/Level/Space.tscn")
