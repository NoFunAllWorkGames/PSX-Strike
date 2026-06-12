extends Node

# The signals are usually not used in this file
# but all IDEs will complain about it, so we ignore it
@warning_ignore_start("unused_signal")

# UI
## General
signal update_ui()

## Space
signal display_action_label(message: String)
signal display_asteroid_lifebar(asteroid: Asteroid)
signal clear_asteroid_lifebar()
signal player_resource_received_view_update(amount: int)
signal cargo_state_changed(amount: int, capacity: int)

## Station
signal right_column_updated()

## Player Ship
signal player_receive_damage(amount: int)

## Ship control
signal shoot_action_pressed()
signal shoot_action_released()
signal mining_laser_fade_out_requested()

## Inventory
signal player_resource_received(amount: int)

## Environment
signal damage_asteroid(asteroid: Asteroid, amount: float)
