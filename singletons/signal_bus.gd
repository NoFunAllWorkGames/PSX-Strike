extends Node

# Level & Scene
signal scene_transition_started(from_scene: String, to_scene: String)
signal scene_transition_finished(scene_name: String)

# Audio
signal play_sfx_requested(sfx_id: String)
signal play_music_requested(music_id: String)

# UI
signal display_action_label(message: String)
