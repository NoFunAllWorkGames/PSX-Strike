extends Control

@onready var money_value: Label = $MoneyPanel/CenterContainer/MoneyValue
@onready var resource_value: Label = $ResourcePanel/CenterContainer/ResourceValue

func _ready() -> void:
	SignalBus.right_column_updated.connect(_on_right_column_updated)
	# Initial setup
	_on_right_column_updated()
	
func _on_right_column_updated() -> void:
	money_value.text = str(GameManager.station_resources.money_amount)
	resource_value.text = str(GameManager.station_resources.resources_amount)
