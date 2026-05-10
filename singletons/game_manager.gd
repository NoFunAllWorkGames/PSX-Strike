extends Node

var PlayerShip: CharacterBody3D
var previous_scene_path: String = ""

func transition_to(target_path: String) -> void:
	# Store the path of the scene currently being exited
	var current_scene = get_tree().current_scene
	previous_scene_path = current_scene.scene_file_path
	# Logging
	print("Changing scene from: " + previous_scene_path)
	print("Changing scene to: " + target_path)
	# Do the scene change
	var error = get_tree().change_scene_to_file(target_path)
