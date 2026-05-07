extends CharacterBody3D

@export var acceleration: float = 18.0
@export var deceleration: float = 12.0
@export var max_speed: float = 40.0
@export var look_sensitivity: float = 0.003
@export var min_pitch_degrees: float = -45.0
@export var max_pitch_degrees: float = 45.0

@onready var camera_pivot: Node3D = $CameraPivot

var _look_pitch: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	_apply_movement(delta)
	move_and_slide()

# Quick and dirty mouse look
# It should not be in this ship file
# Just for grayboxing
func _unhandled_input(event: InputEvent) -> void:
	# Mouse movement
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * look_sensitivity)
		_look_pitch = clampf(
			_look_pitch - event.relative.y * look_sensitivity,
			deg_to_rad(min_pitch_degrees),
			deg_to_rad(max_pitch_degrees)
		)
		camera_pivot.rotation.x = _look_pitch
	# if the mouse is clicked, capture the mouse
	elif event is InputEventMouseButton and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Release the mouse look on escape
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

## Space movement magic
## Throwaway code for grayboxing
func _apply_movement(delta: float) -> void:
	# The player tries to push forward but have to counteract the still remaining backwards velocity
	var forward_input := Input.get_action_strength("ship_forward") - Input.get_action_strength("ship_back")
	# same but for sideways movement
	var strafe_input := Input.get_action_strength("ship_strafe_right") - Input.get_action_strength("ship_strafe_left")

	var target_velocity: Vector3 = Vector3.ZERO
	var move_input := Vector2(strafe_input, forward_input)
	if move_input.length_squared() > 0.0:
		move_input = move_input.normalized()
		target_velocity = (
			global_basis.x * move_input.x +
			-global_basis.z * move_input.y
		) * max_speed

	var blend_weight := acceleration if target_velocity != Vector3.ZERO else deceleration
	velocity = velocity.move_toward(target_velocity, blend_weight * delta)
