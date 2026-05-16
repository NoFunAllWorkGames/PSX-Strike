extends Node

# The signals are usually not used in this file
# but all IDEs will complain about it, so we ignore it
@warning_ignore_start("unused_signal")

# Level & Scene
signal scene_transition_started(from_scene: String, to_scene: String)
signal scene_transition_finished(scene_name: String)

# UI
signal display_action_label(message: String)
signal display_asteroid_lifebar(asteroid: Asteroid)
signal clear_asteroid_lifebar()
signal player_resource_received_view_update(amount: int)

# Ship control
signal shoot_action_pressed()
signal shoot_action_released()

# Inventory
signal player_resource_received(amount: int)

# Environment
signal damage_asteroid(asteroid: Asteroid, amount: float)
