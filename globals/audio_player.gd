extends Node

const MENU_PAUSE_PLAYER := preload("res://scenes/SoundNodes/MenuPausePlayer.tscn")
const MENU_RESUME_PLAYER := preload("res://scenes/SoundNodes/MenuResumePlayer.tscn")
const MENU_ERROR_PLAYER := preload("res://scenes/SoundNodes/MenuErrorPlayer.tscn")
const BUTTON_CLICK_PLAYER := preload("res://scenes/SoundNodes/ButtonClickPlayer.tscn")
const BUTTON_HOVER_PLAYER := preload("res://scenes/SoundNodes/ButtonHoverPlayer.tscn")
const MINING_LASER_MISS_FADE_OUT_PLAYER := preload("res://scenes/SoundNodes/MiningLaserMissFadeOutPlayer.tscn")
const ASTEROID_BLAST_PLAYER := preload("res://scenes/SoundNodes/AsteroidBlastPlayer.tscn")
const ASTEROID_COLLISION_PLAYER := preload("res://scenes/SoundNodes/AsteroidCollisionPlayer.tscn")

func _ready() -> void:
	SignalBus.mining_laser_fade_out_requested.connect(_on_mining_laser_fade_out_requested)

func _on_mining_laser_fade_out_requested() -> void:
	play_mining_laser_miss_fade_out()

func play_audio_stream(scene: PackedScene) -> void:
	var audio_device := scene.instantiate() as AudioStreamPlayer
	get_tree().root.add_child.call_deferred(audio_device)
	if not audio_device.is_node_ready():
		await audio_device.ready
	audio_device.play()
	await audio_device.finished
	audio_device.queue_free()

func play_pausemenu_open() -> void:
	play_audio_stream(MENU_PAUSE_PLAYER)

func play_pausemenu_close() -> void:
	play_audio_stream(MENU_RESUME_PLAYER)

func play_ui_error() -> void:
	play_audio_stream(MENU_ERROR_PLAYER)

func play_ui_button_click() -> void:
	play_audio_stream(BUTTON_CLICK_PLAYER)

func play_ui_button_hover() -> void:
	play_audio_stream(BUTTON_HOVER_PLAYER)

func play_mining_laser_miss_fade_out() -> void:
	play_audio_stream(MINING_LASER_MISS_FADE_OUT_PLAYER)

func play_asteroid_blast() -> void:
	play_audio_stream(ASTEROID_BLAST_PLAYER)

func play_asteroid_collision() -> void:
	play_audio_stream(ASTEROID_COLLISION_PLAYER)
