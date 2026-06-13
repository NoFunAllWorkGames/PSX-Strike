extends ProgressBar

const HIDE_AFTER_DAMAGE_SEC := 2.0

var owner_asteroid: Asteroid

@onready var sprite: Sprite3D = $"../../Sprite3D"
@onready var hide_timer: Timer = $"../Timer"

func _ready() -> void:
	# get grandparent node (Asteroid) to make each asteroid unique
	owner_asteroid = get_parent().get_parent() as Asteroid
	sprite.visible = false

	hide_timer.timeout.connect(_on_hide_timer_timeout)
	SignalBus.display_asteroid_lifebar.connect(_on_display_asteroid_lifebar)
	SignalBus.clear_asteroid_lifebar.connect(_on_clear_asteroid_lifebar)

func _on_display_asteroid_lifebar(asteroid: Asteroid) -> void:
	if asteroid != owner_asteroid:
		return
	if not is_instance_valid(asteroid) or asteroid.max_health <= 0.0:
		return

	sprite.visible = true
	max_value = asteroid.max_health
	value = asteroid.health
	hide_timer.stop()
	hide_timer.start()

func _on_hide_timer_timeout() -> void:
	visible = false

func _on_clear_asteroid_lifebar() -> void:
	hide_timer.stop()
	visible = false
