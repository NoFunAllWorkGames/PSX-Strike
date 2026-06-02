extends MarginContainer

@export var health_progress_bar: ProgressBar
@export var speed_progress_bar: ProgressBar

func _ready() -> void:
	SignalBus.player_receive_damage.connect(_on_player_receive_damage)
	SignalBus.update_ui.connect(_sync_speed_bar_max)
	_sync_speed_bar_max()

func _process(_delta: float) -> void:
	_update_speed_bar()

func _sync_speed_bar_max() -> void:
	var player := GameManager.PlayerShip
	speed_progress_bar.max_value = player.max_speed
	health_progress_bar.max_value = player.max_lifepoints
	health_progress_bar.value = player.lifepoints

func _update_speed_bar() -> void:
	var player := GameManager.PlayerShip
	speed_progress_bar.value = player.speed

func _on_player_receive_damage(amount: int) -> void:
	health_progress_bar.value -= amount
