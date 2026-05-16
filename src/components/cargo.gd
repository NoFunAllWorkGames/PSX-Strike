class_name CargoComponent
extends Node3D

@export var cargo_capacity: int = 100
@export var cargo_amount: int = 0

func _ready() -> void:
	SignalBus.player_resource_received.connect(_on_player_resource_received)

func _on_player_resource_received(amount: int) -> void:
	cargo_amount += amount
	if cargo_amount > cargo_capacity:
		cargo_amount = cargo_capacity
	SignalBus.player_resource_received_view_update.emit(cargo_amount)
