extends RigidBody3D

@export var speed: float = 10.0
@export var enemy_ship_data: EnemyShipData = EnemyShipData.new()

func _physics_process(_delta: float) -> void:
	linear_velocity = enemy_ship_data.direction_start * enemy_ship_data.speed
