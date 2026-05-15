extends Node

@export var enemy_scene: PackedScene = preload("res://scenes/Ships/enemy_ship_rando.tscn")
@export var enemy_ship_data: EnemyShipData = preload("res://src/ships/enemy_ship_rando.tres")
@export var border_area: Area3D

@onready var enemySpawnTreePoint := $"../../HBoxContainer/SubViewportContainer/SubViewport/World/Enemies"

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
			spawn_enemy_from_slot(slot)

func spawn_enemy_at(global_position: Vector3) -> RigidBody3D:
	var data: EnemyShipData = enemy_ship_data.duplicate(true) as EnemyShipData
	data.starting_point = global_position + data.starting_point
	return _spawn_with_data(data)


func spawn_enemy_from_slot(slot: EnemySpawnSlot) -> RigidBody3D:
	var data: EnemyShipData = slot.enemy_ship_data.duplicate(true) as EnemyShipData
	var enemy
	if slot.random_start:
		_apply_random_starting_point(data)
		enemy = _spawn_with_data(data)
	return enemy 


func _apply_random_starting_point(data: EnemyShipData) -> void:
	var spawn_point: Vector3 = border_area.get_random_point_on_box_surface()
	var direction: Vector3 = border_area.get_random_direction_vector(spawn_point)
	data.direction = direction
	data.starting_point = spawn_point


func _spawn_with_data(data: EnemyShipData) -> RigidBody3D:
	var new_ship_instance := enemy_scene.instantiate() as RigidBody3D
	new_ship_instance.enemy_ship_data = data
	enemySpawnTreePoint.add_child(new_ship_instance)
	new_ship_instance.global_position = data.starting_point
	return new_ship_instance
