extends Node

func _ready() -> void:
	SignalBus.mining_laser_fade_out_requested.connect(_on_mining_laser_fade_out_requested)

func _on_mining_laser_fade_out_requested() -> void:
	play_mining_laser_miss_fade_out()

func play_audio_stream(scene_path: String) -> void:
	var audio_device := load(scene_path).instantiate() as AudioStreamPlayer
	get_tree().root.add_child.call_deferred(audio_device)
	if not audio_device.is_node_ready():
		await audio_device.ready
	audio_device.play()
	await audio_device.finished
	audio_device.queue_free()

func play_pausemenu_open() -> void:
	const scene_path = "res://scenes/SoundNodes/MenuPausePlayer.tscn"
	play_audio_stream(scene_path)

func play_pausemenu_close() -> void:
	const scene_path = "res://scenes/SoundNodes/MenuResumePlayer.tscn"
	play_audio_stream(scene_path)

func play_ui_error() -> void:
	const scene_path = "res://scenes/SoundNodes/MenuErrorPlayer.tscn"
	play_audio_stream(scene_path)

func play_ui_button_click() -> void:
	const scene_path = "res://scenes/SoundNodes/ButtonClickPlayer.tscn"
	play_audio_stream(scene_path)

func play_ui_button_hover() -> void:
	const scene_path = "res://scenes/SoundNodes/ButtonHoverPlayer.tscn"
	play_audio_stream(scene_path)

func play_mining_laser_miss_fade_out() -> void:
	const scene_path = "res://scenes/SoundNodes/MiningLaserMissFadeOutPlayer.tscn"
	play_audio_stream(scene_path)
