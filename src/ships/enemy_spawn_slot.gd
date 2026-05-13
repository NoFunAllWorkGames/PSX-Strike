extends Resource
class_name EnemySpawnSlot

const DEFAULT_ENEMY_SHIP_DATA := preload("res://src/ships/enemy_ship_rando.tres")

@export var enemy_scene: PackedScene = preload("res://scenes/Ships/enemy_ship_rando.tscn")
@export var enemy_ship_data: EnemyShipData = DEFAULT_ENEMY_SHIP_DATA
@export var random_start: bool = true

func _init() -> void:
	if enemy_ship_data == null:
		enemy_ship_data = DEFAULT_ENEMY_SHIP_DATA


func _notification(what: int) -> void:
	if what == NOTIFICATION_POSTINITIALIZE and enemy_ship_data == null:
		enemy_ship_data = DEFAULT_ENEMY_SHIP_DATA
