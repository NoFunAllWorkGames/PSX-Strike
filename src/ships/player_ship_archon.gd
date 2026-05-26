extends CharacterBody3D

## Controls
@export var acceleration: float = 5.0
@export var deceleration: float = 12.0
@export var max_speed: float = 40.0
@export var engine_hover_pitch_at_rest: float = 1.0
@export var engine_hover_pitch_at_max_speed: float = 4.0
@export var pitch_speed_degrees: float = 75.0
@export var look_sensitivity: float = 0.003
@export var min_pitch_degrees: float = -45.0
@export var max_pitch_degrees: float = 45.0

## Health
@export var lifepoints: int = 100

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var engine_hovering: AudioStreamPlayer = $Engine_Hovering
@onready var current_weapon = preload("res://scenes/Objects/mining_laser.tscn")
@onready var dying_explosion: AudioStreamPlayer = $DyingExplosion
@onready var explosion_animation: AnimationPlayer = $ExplosionAnimation

var _ship_yaw: float = 0.0
var _look_pitch: float = 0.0

func _enter_tree() -> void:
	InputManager.capture_mouse()
	InputManager.enable_freelook_click_capture = true
	InputManager.mouse_look_relative.connect(_on_mouse_look_relative)

func _ready() -> void:
	_ship_yaw = rotation.y
	_look_pitch = rotation.x
	camera_pivot.rotation = Vector3.ZERO
	SignalBus.player_receive_damage.connect(_on_player_receive_damage)

func _exit_tree() -> void:
	InputManager.enable_freelook_click_capture = false
	InputManager.mouse_look_relative.disconnect(_on_mouse_look_relative)

func _physics_process(delta: float) -> void:
	_apply_pitching(delta)
	_apply_movement(delta)
	move_and_slide()
	_update_engine_hovering_pitch()

func _on_mouse_look_relative(relative: Vector2) -> void:
	# TODO: This is checked too often
	# It is supposed to cover the case that undock_ship() pushes
	# the player and change the camera, but
	# mouselook isn't updated
	# Reason why this was added is that the view
	# was flipped after undocking
	_ship_yaw = rotation.y
	_look_pitch = rotation.x

	# Apply the incoming mouse delta as normal
	_ship_yaw -= relative.x * look_sensitivity
	_look_pitch = clampf(
		_look_pitch - relative.y * look_sensitivity,
		deg_to_rad(min_pitch_degrees),
		deg_to_rad(max_pitch_degrees)
	)
	rotation = Vector3(_look_pitch, _ship_yaw, 0.0)

## Space movement magic
## Throwaway code for grayboxing
func _apply_pitching(delta: float) -> void:
	var pitch_input := InputManager.get_ship_pitch_axis()
	if is_zero_approx(pitch_input):
		return

	var delta_rad := pitch_input * deg_to_rad(pitch_speed_degrees) * delta
	_look_pitch = clampf(
		_look_pitch + delta_rad,
		deg_to_rad(min_pitch_degrees),
		deg_to_rad(max_pitch_degrees)
	)
	rotation = Vector3(_look_pitch, _ship_yaw, 0.0)

func _apply_movement(delta: float) -> void:
	var forward_input := InputManager.get_ship_forward_axis()
	var strafe_input := InputManager.get_ship_strafe_axis()
	var vertical_input := InputManager.get_ship_vertical_axis()

	var target_velocity: Vector3 = Vector3.ZERO
	var local_dir: Vector3 = Vector3(strafe_input, vertical_input, -forward_input)
	if local_dir.length_squared() > 0.0:
		local_dir = local_dir.normalized()
		target_velocity = (
			global_basis.x * local_dir.x +
			global_basis.y * local_dir.y +
			global_basis.z * local_dir.z
		) * max_speed

	var blend_weight := acceleration if target_velocity != Vector3.ZERO else deceleration
	velocity = velocity.move_toward(target_velocity, blend_weight * delta)

func _update_engine_hovering_pitch() -> void:
	var speed_ratio := 0.0
	if max_speed > 0.0:
		speed_ratio = clampf(velocity.length() / max_speed, 0.0, 1.0)
	engine_hovering.pitch_scale = lerpf(
		engine_hover_pitch_at_rest,
		engine_hover_pitch_at_max_speed,
		speed_ratio
	)

func _on_player_receive_damage(damage: int) -> void:
	lifepoints -= damage
	if lifepoints <= 0:

		go_die()

func go_die() -> void:

	explosion_animation.play("explosion")

	# stop player control
	set_physics_process(false)
	InputManager.enable_freelook_click_capture = false
	InputManager.release_mouse()

	await explosion_animation.animation_finished

	# show deathscreen
	explosion_animation.play("RESET")
	# release controls again
	# restart the game
	GameManager.restart_game()
