extends Control

@onready var undock_button = get_node("MarginContainer/HBoxContainer/VBoxContainer/undock")

func _ready() -> void:
	InputManager.release_mouse()
	undock_button.pressed.connect(_on_undock_pressed)

func _on_undock_pressed() -> void:
	print("Undock button pressed")
	GameManager.transition_to("res://scenes/Space.tscn")
