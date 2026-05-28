extends Node

func _ready() -> void:
	SignalBus.shoot_action_pressed.connect(_on_shoot_action_pressed)
	SignalBus.shoot_action_released.connect(_on_shoot_action_released)

func _on_shoot_action_pressed():
	if GameManager.player_is_dead:
		return
	if GameManager.weapon_system.weapon_id == "mining_laser":
		var mining_laser_res: PackedScene = GameManager.weapon_system.scene_path as PackedScene
		var mining_laser_instance: Node3D = mining_laser_res.instantiate() as Node3D
		add_child(mining_laser_instance)

func _on_shoot_action_released():
	for child in get_children():
		child.queue_free()
