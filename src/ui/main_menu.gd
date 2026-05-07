extends CanvasLayer

@export var start_scene: PackedScene

@onready var start_button: Button = $Control/MarginContainer/VBoxContainer/VBoxContainer/Start
@onready var quit_button: Button = $Control/MarginContainer/VBoxContainer/VBoxContainer/Quit

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	if start_scene == null:
		return
	get_tree().change_scene_to_file.call_deferred(start_scene.resource_path)

func _on_quit_pressed() -> void:
	get_tree().quit()
