extends Resource
class_name WeaponData

# This is the current available weapons for the player
# It should have multiple slots, currently we only use one weapon
@export var weapon_id: String
@export var weapon_name: String
@export var scene_path: PackedScene
