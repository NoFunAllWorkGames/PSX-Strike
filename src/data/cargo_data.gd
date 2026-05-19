class_name CargoData
extends Resource

@export var cargo_capacity: int = 100
@export var cargo_amount: int = 0

func add_cargo(amount: int) -> void:
	cargo_amount += amount
	if cargo_amount > cargo_capacity:
		cargo_amount = cargo_capacity

func unload_all_resources() -> int:
	var return_amount: int = cargo_amount
	cargo_amount = 0
	return return_amount
