extends RigidBody3D

@export var enemy_ship_data: EnemyShipData = EnemyShipData.new()
@onready var shoot_timer: Timer = $ShootTimer
@onready var detection_range: Area3D = $DetectionRange
@onready var gatling_component: EnemyGatlingComponent = $Components/GatlingComponent

func _physics_process(_delta: float) -> void:
	# Move in the local forward direction (negative Z)
	linear_velocity = -global_transform.basis.z * enemy_ship_data.speed

func _ready() -> void:
	start_enemy_scanning()

func start_enemy_scanning() -> void:
	while(true):
		# just do it as often as the timer says, else we would be checking too fast
		await shoot_timer.timeout
		var is_player_in_range: bool = not detection_range.get_overlapping_bodies().is_empty()
		if is_player_in_range:
			var player_ship = detection_range.get_overlapping_bodies()[0]
			if _is_body_in_front_half(player_ship):
				gatling_component.is_firing = true
			else:
				gatling_component.is_firing = false
		else:
			gatling_component.is_firing = false
	
func _is_body_in_front_half(target_body: Node3D) -> bool:
	var local_pos: Vector3 = detection_range.to_local(target_body.global_position)
	# Negative Z is forward in Godot, so z < 0.0 is in front
	return local_pos.z < 0.0
