extends CharacterBody3D

@export var acceleration: float = 18.0
@export var deceleration: float = 12.0
@export var max_speed: float = 40.0
@export var turn_speed_degrees: float = 90.0
@export var pitch_speed_degrees: float = 75.0
@export var look_sensitivity: float = 0.003
@export var min_pitch_degrees: float = -45.0
@export var max_pitch_degrees: float = 45.0
@export var camera_yaw_limit_degrees: float = 170.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = $CameraPivot/SpringArm3D/Camera3D

var _look_pitch: float = 0.0
var _camera_yaw: float = 0.0

func _ready() -> void:
	InputManager.capture_mouse()
	InputManager.enable_freelook_click_capture = true
	InputManager.mouse_look_relative.connect(_on_mouse_look_relative)
	_camera_yaw = camera_pivot.rotation.y

func _exit_tree() -> void:
	InputManager.enable_freelook_click_capture = false
	InputManager.mouse_look_relative.disconnect(_on_mouse_look_relative)

func _physics_process(delta: float) -> void:
	_apply_turning(delta)
	_apply_pitching(delta)
	_apply_movement(delta)
	move_and_slide()

# Quick and dirty mouse look (driven by InputManager); should not live here long-term — grayboxing only.
func _on_mouse_look_relative(relative: Vector2) -> void:
	var yaw_delta: float = -relative.x * look_sensitivity
	var desired_yaw: float = _camera_yaw + yaw_delta

	var yaw_limit: float = deg_to_rad(camera_yaw_limit_degrees)
	if desired_yaw > yaw_limit:
		var pivot_delta: float = yaw_limit - _camera_yaw
		var ship_delta: float = yaw_delta - pivot_delta
		_camera_yaw = yaw_limit
		rotate_y(ship_delta)
	elif desired_yaw < -yaw_limit:
		var pivot_delta: float = -yaw_limit - _camera_yaw
		var ship_delta: float = yaw_delta - pivot_delta
		_camera_yaw = -yaw_limit
		rotate_y(ship_delta)
	else:
		_camera_yaw = desired_yaw

	_look_pitch = clampf(
		_look_pitch - relative.y * look_sensitivity,
		deg_to_rad(min_pitch_degrees),
		deg_to_rad(max_pitch_degrees)
	)
	camera_pivot.rotation.y = _camera_yaw
	camera_pivot.rotation.x = _look_pitch

## Space movement magic
## Throwaway code for grayboxing
func _apply_turning(delta: float) -> void:
	var turn_input := InputManager.get_ship_yaw_axis()
	if is_zero_approx(turn_input):
		return

	rotate_y(turn_input * deg_to_rad(turn_speed_degrees) * delta)

func _apply_pitching(delta: float) -> void:
	var pitch_input := InputManager.get_ship_pitch_axis()
	if is_zero_approx(pitch_input):
		return

	rotate_object_local(Vector3.RIGHT, pitch_input * deg_to_rad(pitch_speed_degrees) * delta)

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
