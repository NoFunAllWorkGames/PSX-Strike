extends MarginContainer

const OVERSPEED_TEXT := "Overspeed!"
const OVERSPEED_FONT_COLOR := Color(1.0, 0.15, 0.15)
const HEALTH_FONT_SIZE := 8

@export var health_progress_bar: ProgressBar

var _health_overlay_label: Label

func _ready() -> void:
	health_progress_bar.show_percentage = false
	_setup_health_bar_overlay()
	SignalBus.update_ui.connect(_sync_health_bar)
	_sync_health_bar()

func _setup_health_bar_overlay() -> void:
	var slot := Control.new()
	slot.name = "HealthBarSlot"
	slot.custom_minimum_size = health_progress_bar.custom_minimum_size
	slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var bar_index := health_progress_bar.get_index()
	health_progress_bar.reparent(slot)
	health_progress_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_health_overlay_label = Label.new()
	_health_overlay_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_health_overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_health_overlay_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_health_overlay_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_health_overlay_label.add_theme_font_size_override("font_size", HEALTH_FONT_SIZE)
	slot.add_child(_health_overlay_label)

	add_child(slot)
	move_child(slot, bar_index)

func _process(_delta: float) -> void:
	var player := GameManager.PlayerShip
	health_progress_bar.value = player.lifepoints
	_update_health_overlay(player)

func _sync_health_bar() -> void:
	var player := GameManager.PlayerShip
	health_progress_bar.max_value = player.max_lifepoints
	_update_health_overlay(player)

func _update_health_overlay(player: CharacterBody3D) -> void:
	if player.is_overspeed_warning():
		_health_overlay_label.text = OVERSPEED_TEXT
		_health_overlay_label.add_theme_color_override("font_color", OVERSPEED_FONT_COLOR)
		return

	_health_overlay_label.remove_theme_color_override("font_color")
	if health_progress_bar.max_value <= 0.0:
		_health_overlay_label.text = "0%"
		return
	var percent := int(round(health_progress_bar.value / health_progress_bar.max_value * 100.0))
	_health_overlay_label.text = "%d%%" % percent
