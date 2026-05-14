extends Node

const RANDOM_START_EXTRUDE: float = 100.0

@export var enemy_scene: PackedScene = preload("res://scenes/Ships/enemy_ship_rando.tscn")
@export var enemy_ship_data: EnemyShipData = preload("res://src/ships/enemy_ship_rando.tres")
@export var border_area: Area3D

@onready var enemySpawnTreePoint := $"../../World/Enemies"

@export_storage var _enemy_spawn_slots: Array[EnemySpawnSlot] = []

@export var enemy_spawn_slots: Array[EnemySpawnSlot]:
	get:
		return _enemy_spawn_slots
	set(value):
		for slot in value:
			if slot != null and slot.enemy_ship_data == null:
				slot.enemy_ship_data = EnemySpawnSlot.DEFAULT_ENEMY_SHIP_DATA
		_enemy_spawn_slots = value


func _ready() -> void:
	for slot in _enemy_spawn_slots:
		if slot != null:
			var enemy_ship := spawn_enemy_from_slot(slot, Vector3.ZERO)
			enemySpawnTreePoint.add_child(enemy_ship)

func spawn_enemy_at(global_position: Vector3) -> RigidBody3D:
	var data: EnemyShipData = enemy_ship_data.duplicate(true) as EnemyShipData
	return _spawn_with_data(data, global_position)


func spawn_enemy_from_slot(slot: EnemySpawnSlot, origin_point: Vector3) -> RigidBody3D:
	var data: EnemyShipData = slot.enemy_ship_data.duplicate(true) as EnemyShipData
	var enemy
	if slot.random_start:
		_apply_random_starting_point(data, origin_point)
		enemy = _spawn_with_data(data, origin_point)
	return enemy 


func _apply_random_starting_point(data: EnemyShipData, origin_point: Vector3) -> void:
	var edge_point: Vector3 = border_area.get_random_point_on_any_edge()
	var direction: Vector3 = border_area.get_random_direction_vector()
	var world_spawn: Vector3 = edge_point + direction * RANDOM_START_EXTRUDE
	data.starting_point = world_spawn - origin_point


func _spawn_with_data(data: EnemyShipData, origin_point: Vector3) -> RigidBody3D:
	var new_ship_instance := enemy_scene.instantiate() as RigidBody3D
	new_ship_instance.enemy_ship_data = data
	enemySpawnTreePoint.add_child(new_ship_instance)
	new_ship_instance.global_position = origin_point + data.starting_point
	return new_ship_instance
