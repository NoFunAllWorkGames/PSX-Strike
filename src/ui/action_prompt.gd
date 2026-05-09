extends Label


func _ready() -> void:
	SignalBus.display_action_label.connect(_on_display_action_label)

func _on_display_action_label(message: String) -> void:
	text = message
	visible = message != ""
