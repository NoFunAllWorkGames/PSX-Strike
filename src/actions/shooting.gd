extends Node

var player :CharacterBody3D

func _ready() -> void:
	SignalBus.shoot_action_pressed.connect(_on_shoot_action_pressed)
	SignalBus.shoot_action_released.connect(_on_shoot_action_released)
	player = GameManager.PlayerShip as CharacterBody3D
	
func _on_shoot_action_pressed():
	if player.current_weapon.resource_path == "res://scenes/Actions/mining_laser.tscn":
		var mining_laser_instance = player.current_weapon.instantiate()
		add_child(mining_laser_instance)

func _on_shoot_action_released():
	for child in get_children():
		child.queue_free()
