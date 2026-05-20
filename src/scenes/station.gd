extends Node

const StationResourcesDataFile = preload("res://src/data/station_resources_data.gd")

func _ready() -> void:
	GameManager.game_state = Enums.GameState.STATION
	var unloaded_amount: int = GameManager.cargo.unload_all_resources()
	GameManager.station_resources.resources_amount += unloaded_amount
	# seemingly the node tree isn't built yet. So this doesn't work
	SignalBus.right_column_updated.emit()

func _on_sell_pressed() -> void:
	if GameManager.station_resources.resources_amount == 0:
		return
	var current_station_money = GameManager.station_resources.money_amount
	var converted_money = GameManager.station_resources.convert_all_resources_to_money()
	var money_amount = current_station_money + converted_money
	GameManager.station_resources.money_amount = money_amount
	SignalBus.right_column_updated.emit()
