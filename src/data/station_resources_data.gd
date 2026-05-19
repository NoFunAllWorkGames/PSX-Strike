class_name StationResourcesData
extends Resource

@export var resources_amount: int = 0
@export var money_amount: int = 0

func convert_all_resources_to_money() -> int:
	var return_money = resources_amount
	resources_amount = 0
	return return_money

func convert_resources_to_money(amount: int) -> void:
	money_amount += amount
	resources_amount = 0

func add_resources_from_docking_ship(amount: int) -> void:
	resources_amount += amount
