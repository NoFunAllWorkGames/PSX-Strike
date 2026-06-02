class_name SaveGameData
extends Resource

const SpaceWorldStateResource := preload("res://src/data/space_world_state.gd")

@export var player_ship_scene: PackedScene

# Resources
@export var cargo: CargoData
@export var station_resources: StationResourcesData
@export var weapon_system: WeaponData
@export var space_world_state: SpaceWorldStateResource

# State and Transforms
@export var game_state: Enums.GameState
@export var previous_scene_path: String
@export var current_scene_path: String
@export var saved_player_transform: Transform3D
