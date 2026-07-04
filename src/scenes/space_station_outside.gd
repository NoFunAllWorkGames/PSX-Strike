extends Node

const STATION_SOFT_SOUND: AudioStream = preload("res://assets/Sounds/Collisions/WithStation/CollisionStnSoft.ogg")
const STATION_MED_SOUND: AudioStream = preload("res://assets/Sounds/Collisions/WithStation/CollisionStnMed.ogg")
const STATION_HARD_SOUND: AudioStream = preload("res://assets/Sounds/Collisions/WithStation/CollisionStnHard.ogg")

const MIN_IMPACT_SPEED := 2.0
const STATION_SOFT_MAX_SPEED := 12.0
const STATION_MED_MAX_SPEED := 26.0

var _player_in_dock_zone: bool = false

@export var space_station_entry_area: Area3D
@export var hull_contact_area: Area3D

@onready var _collision_audio: AudioStreamPlayer = $CollisionAudio

func _ready() -> void:
	space_station_entry_area.body_entered.connect(_on_area_3d_body_entered)
	space_station_entry_area.body_exited.connect(_on_area_3d_body_exited)
	hull_contact_area.body_entered.connect(_on_hull_contact_play_sound)
	InputManager.interact_pressed.connect(_on_interact_pressed)

func _exit_tree() -> void:
	space_station_entry_area.body_entered.disconnect(_on_area_3d_body_entered)
	space_station_entry_area.body_exited.disconnect(_on_area_3d_body_exited)
	hull_contact_area.body_entered.disconnect(_on_hull_contact_play_sound)
	InputManager.interact_pressed.disconnect(_on_interact_pressed)

func _on_interact_pressed() -> void:
	if not _player_in_dock_zone:
		return
	GameManager.transition_to("res://scenes/Level/Station.tscn")

func _on_area_3d_body_entered(_body: Node3D) -> void:
	_player_in_dock_zone = true
	var interact_label := UserSettings.get_binding_label(UserSettings.INTERACT_ACTION)
	SignalBus.display_action_label.emit("Press %s to enter" % interact_label)

func _on_area_3d_body_exited(_body: Node3D) -> void:
	_player_in_dock_zone = false
	SignalBus.display_action_label.emit("")

func _on_hull_contact_play_sound(body: Node3D) -> void:
	if body != GameManager.PlayerShip:
		return
	if _player_in_dock_zone:
		return

	var impact_speed: float = body.velocity.length()
	if impact_speed < MIN_IMPACT_SPEED:
		return

	_collision_audio.stream = _station_sound_for_impact(impact_speed)
	_collision_audio.play()

func _station_sound_for_impact(impact_speed: float) -> AudioStream:
	if impact_speed < STATION_SOFT_MAX_SPEED:
		return STATION_SOFT_SOUND
	if impact_speed < STATION_MED_MAX_SPEED:
		return STATION_MED_SOUND
	return STATION_HARD_SOUND
