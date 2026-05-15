extends Node

# The signals are usually not used in this file
# but all IDEs will complain about it, so we ignore it
@warning_ignore_start("unused_signal")

# Level & Scene
signal scene_transition_started(from_scene: String, to_scene: String)
signal scene_transition_finished(scene_name: String)

# Audio
signal play_sfx_requested(sfx_id: String)
signal play_music_requested(music_id: String)

# UI
signal display_action_label(message: String)

# Ship control
signal shoot_action_pressed()
signal shoot_action_released()
