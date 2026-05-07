extends Node

@export var settings: GameSettingsResource

var current_run: RunData = null

var has_active_run: bool:
	get: return current_run != null

var pending_stage_scene: String = ""
var pending_entry_id: String = ""

signal run_started(run: RunData)
signal run_ended()

func _ready() -> void:
	if settings == null:
		settings = GameSettingsResource.new()

func start_new_run() -> void:
	current_run = RunData.new()
	run_started.emit(current_run)

func resume_run(saved_run: RunData) -> void:
	current_run = saved_run
	run_started.emit(current_run)

func end_run() -> void:
	current_run = null
	run_ended.emit()
