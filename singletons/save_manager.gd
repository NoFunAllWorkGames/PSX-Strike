extends Node

const SAVE_FILE := "user://save.json"
const SAVE_VERSION := 1
var timestamp: String = ""
var is_empty: bool = true

signal save_completed()
signal load_completed(run: RunData)
signal save_failed(error: String)

# TODO: Create error feedback not just null
func save() -> void:
	var run :RunData = GameManager.current_run
	if run == null:
		save_failed.emit("No active run")
		return
	var data := {
		"saved_at": Time.get_datetime_string_from_system(),
		"version": SAVE_VERSION,
		"run": _serialize_run(run)
	}
	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file == null:
		save_failed.emit("Cannot write to " + SAVE_FILE)
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	save_completed.emit()

# TODO: Create error feedback not just null
func load() -> RunData:
	if not FileAccess.file_exists(SAVE_FILE):
		return null
	var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file == null:
		return null
	var json: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (json is Dictionary) or not _is_valid(json):
		return null
	var run := _deserialize_run(json["run"])
	load_completed.emit(run)
	return run


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)

## Queues a deferred save to avoid writing mid-physics.
func auto_save() -> void:
	call_deferred("save")

func _is_valid(data: Dictionary) -> bool:
	return data.has("version") and data.has("run")

## Converts a RunData resource into a plain Dictionary
# TODO: Add specific data to be saved
func _serialize_run(run: RunData) -> Dictionary:
	return {}

## Reconstructs a RunData resource from a saved Dictionary.
func _deserialize_run(data: Dictionary) -> RunData:
	var run := RunData.new()
	return run
