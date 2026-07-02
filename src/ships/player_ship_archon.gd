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
@export var max_lifepoints: int = 100
@export var lifepoints: int = 100

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var engine_hovering: AudioStreamPlayer = $Engine_Hovering
@onready var current_weapon = preload("res://scenes/Objects/mining_laser.tscn")
@onready var explosion_animation: AnimationPlayer = $ExplosionAnimation
@onready var disintegration_animation: AnimationPlayer = $disintegration

# For self-destruction by max speed
const SUSTAINED_SPEED_DAMAGE_RATIO := 0.95
const SUSTAINED_SPEED_WARNING_RATIO := 0.85
const SUSTAINED_SPEED_DAMAGE_RESET_RATIO := 0.85
var speed: float = 0.0
var speed_timer: float = 0.0

var _ship_yaw: float = 0.0
var _look_pitch: float = 0.0
var _is_dead: bool = false
var _pending_death_effect: SignalBus.PlayerDeathEffect = SignalBus.PlayerDeathEffect.DISINTEGRATION

@export var mesh_instance: MeshInstance3D

func _enter_tree() -> void:
	InputManager.capture_mouse()
	InputManager.enable_freelook_click_capture = true
	InputManager.mouse_look_relative.connect(_on_mouse_look_relative)

func _ready() -> void:
	_ship_yaw = rotation.y
	_look_pitch = rotation.x
	camera_pivot.rotation = Vector3.ZERO
	_setup_disintegrate_shader()
	SignalBus.player_receive_damage.connect(_on_player_receive_damage)

func _exit_tree() -> void:
	InputManager.enable_freelook_click_capture = false
	InputManager.mouse_look_relative.disconnect(_on_mouse_look_relative)

func _physics_process(delta: float) -> void:
	_apply_movement(delta)
	move_and_slide()
	speed = velocity.length()
	_max_speed_selfdestruction(delta)
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
	var sensitivity: float = UserSettings.mouse_sensitivity
	_ship_yaw -= relative.x * sensitivity
	_look_pitch = clampf(
		_look_pitch - relative.y * sensitivity,
		deg_to_rad(min_pitch_degrees),
		deg_to_rad(max_pitch_degrees)
	)
	rotation = Vector3(_look_pitch, _ship_yaw, 0.0)

## Space movement magic
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

func is_overspeed_warning() -> bool:
	return speed >= max_speed * SUSTAINED_SPEED_WARNING_RATIO

func _max_speed_selfdestruction(delta: float) -> void:
	var damage_threshold := max_speed * SUSTAINED_SPEED_DAMAGE_RATIO
	var reset_threshold := max_speed * SUSTAINED_SPEED_DAMAGE_RESET_RATIO

	if speed >= damage_threshold:
		speed_timer += delta
		if speed_timer >= 1.0:
			SignalBus.player_receive_damage.emit(
				1000,
				SignalBus.PlayerDeathEffect.EXPLOSION
			)
			speed_timer = 0.0
	elif speed < reset_threshold:
		speed_timer = 0.0

func _update_engine_hovering_pitch() -> void:
	var speed_ratio := 0.0
	if max_speed > 0.0:
		speed_ratio = clampf(speed / max_speed, 0.0, 1.0)
	engine_hovering.pitch_scale = lerpf(
		engine_hover_pitch_at_rest,
		engine_hover_pitch_at_max_speed,
		speed_ratio
	)

func heal(amount: int) -> int:
	if _is_dead or amount <= 0:
		return 0
	var missing_hp := max_lifepoints - lifepoints
	if missing_hp <= 0:
		return 0
	var healed := mini(amount, missing_hp)
	lifepoints += healed
	return healed


func _on_player_receive_damage(
	damage: int,
	death_effect: SignalBus.PlayerDeathEffect
) -> void:
	if _is_dead:
		return
	_pending_death_effect = death_effect
	lifepoints -= damage
	if lifepoints <= 0:
		go_die()

func go_die() -> void:
	if _is_dead:
		return
	_is_dead = true

	GameManager.halt_simulation_for_player_death()
	SignalBus.shoot_action_released.emit()

	engine_hovering.stop()

	var death_animation: AnimationPlayer
	match _pending_death_effect:
		SignalBus.PlayerDeathEffect.EXPLOSION:
			if mesh_instance:
				mesh_instance.visible = false
			death_animation = explosion_animation
			death_animation.play("explosion")
		_:
			death_animation = disintegration_animation
			death_animation.play("disintegration")

	# post scores via network
	Networking.post_scores()

	# stop player control
	set_physics_process(false)
	InputManager.enable_freelook_click_capture = false
	InputManager.release_mouse()

	await death_animation.animation_finished
	death_animation.play("RESET")
	if death_animation == explosion_animation:
		disintegration_animation.play("RESET")
	else:
		explosion_animation.play("RESET")
	GameManager.open_score_board_overlay()


func _setup_disintegrate_shader() -> void:
	if not mesh_instance or not mesh_instance is MeshInstance3D:
		return

	var cube := mesh_instance as MeshInstance3D
	var shader_mat := cube.get_surface_override_material(0) as ShaderMaterial
	if not shader_mat:
		return

	var surface_mat := cube.mesh.surface_get_material(0)
	if surface_mat is StandardMaterial3D:
		var albedo_texture: Texture2D = surface_mat.albedo_texture
		if albedo_texture:
			shader_mat.set_shader_parameter("albedo_texture", albedo_texture)
