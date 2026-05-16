extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var ship := GameManager.PlayerShip
var cargo

func _ready() -> void:
	SignalBus.player_resource_received_view_update.connect(_on_player_resource_received_view_update)
	
	progress_bar.value = ship.cargo.cargo_amount
	progress_bar.max_value = ship.cargo.cargo_capacity

func _on_player_resource_received_view_update(amount: int) -> void:
	progress_bar.value = amount
