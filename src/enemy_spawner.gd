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
			spawn_enemy_from_slot(slot, Vector3.ZERO)


func spawn_enemy_at(global_position: Vector3) -> RigidBody3D:
	var data: EnemyShipData = enemy_ship_data.duplicate(true) as EnemyShipData
	return _spawn_with_data(data, global_position)


func spawn_enemy_from_slot(slot: EnemySpawnSlot, anchor_global: Vector3) -> RigidBody3D:
	var data: EnemyShipData = slot.enemy_ship_data.duplicate(true) as EnemyShipData
	var enemy
	if slot.random_start:
		_apply_random_starting_point(data, anchor_global)
		enemy = _spawn_with_data(data, anchor_global)
	return enemy 


func _apply_random_starting_point(data: EnemyShipData, anchor_global: Vector3) -> void:
	if border_area == null:
		push_warning("EnemySpawner: random_start requested but border_area is not assigned.")
		return
	var edge_point: Vector3 = border_area.get_random_point_on_any_edge()
	var direction: Vector3 = border_area.get_random_direction_vector()
	var world_spawn: Vector3 = edge_point + direction * RANDOM_START_EXTRUDE
	data.starting_point = world_spawn - anchor_global


func _spawn_with_data(data: EnemyShipData, anchor_global: Vector3) -> RigidBody3D:
	var node := enemy_scene.instantiate()
	var enemy := node as RigidBody3D
	enemy.enemy_ship_data = data
	enemy.speed = data.speed
	enemySpawnTreePoint.add_child(enemy)
	enemy.global_position = anchor_global + data.starting_point
	return enemy
