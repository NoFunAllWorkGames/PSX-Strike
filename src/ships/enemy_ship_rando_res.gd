extends Resource
class_name EnemyShipData

@export_group("Movement")
@export var starting_point: Vector3 = Vector3.ZERO
@export var direction_start: Vector3 = Vector3.FORWARD
@export var direction_end: Vector3 = Vector3.FORWARD
@export var speed: float = 10.0

@export_group("Stats")
@export var max_health: float = 100.0

@export_group("Combat")
@export var fire_rate: float = 1.5
@export var weapon_damage: float = 12.0
