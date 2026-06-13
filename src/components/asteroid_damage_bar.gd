extends MeshInstance3D
class_name AsteroidDamageBar

const HIDE_AFTER_DAMAGE_SEC := 2.0

@onready var _owner: Node3D = get_parent()
@onready var _hide_timer: Timer = $Timer

func _ready() -> void:
	visible = false
	_hide_timer.wait_time = HIDE_AFTER_DAMAGE_SEC
	_hide_timer.timeout.connect(_on_hide_timer_timeout)

func show_health() -> void:
	if _owner.max_health <= 0.0:
		return

	var health_percentage := clampf(_owner.health / _owner.max_health, 0.0, 1.0)
	set_instance_shader_parameter("health_percentage", health_percentage)
	visible = true
	_hide_timer.start()

func hide_bar() -> void:
	_hide_timer.stop()
	visible = false

func _on_hide_timer_timeout() -> void:
	hide_bar()
