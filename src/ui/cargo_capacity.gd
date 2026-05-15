extends Control

@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	# TEMP: simulate cargo filling for HUD testing
	var timer := Timer.new()
	timer.wait_time = 5.0
	timer.autostart = true
	timer.timeout.connect(func() -> void:
		progress_bar.value = minf(progress_bar.value + 5.0, progress_bar.max_value)
	)
	add_child(timer)
