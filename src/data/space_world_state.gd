class_name SpaceWorldState
extends Resource

const SavedTheEntityStateResource := preload("res://src/data/saved_the_entity_state.gd")
const SavedHaulerStateResource := preload("res://src/data/saved_hauler_state.gd")
const SavedAsteroidStateResource := preload("res://src/data/saved_asteroid_state.gd")

@export var the_entity: SavedTheEntityStateResource
@export var haulers: Array[SavedHaulerStateResource] = []
@export var asteroids: Array[SavedAsteroidStateResource] = []
@export var enemy_spawn_counter: int = 1
