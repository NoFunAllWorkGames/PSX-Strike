extends MarginContainer

@export var progress_bar: ProgressBar

func _ready() -> void:
	SignalBus.player_receive_damage.connect(_on_damage_received)

func _on_damage_received(amount: int):
	progress_bar.value -= amount
