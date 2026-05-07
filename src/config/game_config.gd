## Pushes designer config into singletons, then transitions to the first scene
class_name GameConfig
extends Node

## Scene to load immediately after boot. Replace with Main Menu navigation.
@export var next_scene: PackedScene

# _ready(): Applies settings to GameManager, starts a run, loads next_scene.
func _ready() -> void:
	GameManager.start_new_run()
	if next_scene != null:
		LevelManager.load_scene.call_deferred(next_scene.resource_path)
