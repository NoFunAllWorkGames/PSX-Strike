class_name CargoComponent
extends Node

@export var data: CargoData

func _ready() -> void:
	data = GameManager.cargo
	SignalBus.player_resource_received.connect(_on_player_resource_received)
	SignalBus.player_resource_received_view_update.emit(data.cargo_amount)

func _exit_tree() -> void:
	SignalBus.player_resource_received.disconnect(_on_player_resource_received)

func _on_player_resource_received(amount: int) -> void:
	data.add_cargo(amount)
	SignalBus.player_resource_received_view_update.emit(data.cargo_amount)
