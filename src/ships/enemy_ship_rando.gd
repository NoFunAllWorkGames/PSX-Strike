extends RigidBody3D

@onready var ship_RigidBody3D: RigidBody3D = $EnemyShipRando
@export var speed: float = 10.0

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	# Obtain the forward direction vector
	var forward_dir = ship_RigidBody3D.global_transform.basis.z
	
	linear_velocity = forward_dir * speed + Vector3(0, linear_velocity.y, 0)
