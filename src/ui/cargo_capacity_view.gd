extends Control

@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	SignalBus.player_resource_received_view_update.connect(_on_player_resource_received_view_update)
	SignalBus.cargo_state_changed.connect(_on_cargo_state_changed)
	SignalBus.update_ui.connect(_update_ui)
	progress_bar.value = GameManager.cargo.cargo_amount
	progress_bar.max_value = GameManager.cargo.cargo_capacity

func _on_player_resource_received_view_update(amount: int) -> void:
	progress_bar.value = amount

func _on_cargo_state_changed(amount: int, capacity: int) -> void:
	progress_bar.max_value = capacity
	progress_bar.value = amount

func _update_ui() -> void:
	progress_bar.value = GameManager.cargo.cargo_amount
	progress_bar.max_value = GameManager.cargo.cargo_capacity
