extends CanvasLayer

const SCORE_PANEL_SIZE := Vector2(320, 220)
const LINE_BREAK := "\n"

@onready var score_panel: PanelContainer = $Overlay/CenterContainer/ScorePanel
@onready var highscore_label: Label = %HighscoreLabel
@onready var newscore_label: Label = %NewscoreLabel
@onready var myscore_label: Label = %MyscoreLabel
@onready var main_menu_button: Button = %MainMenuButton
@onready var tab_container: TabContainer = $Overlay/CenterContainer/ScorePanel/VBoxContainer/TabContainer

func _ready() -> void:
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	_setup_button_sounds()
	_connect_networking()
	Networking.fetch_all_highscores()

func _exit_tree() -> void:
	_disconnect_networking()

func _connect_networking() -> void:
	Networking.newest_scores_loaded.connect(_on_newest_scores_loaded)
	Networking.highest_scores_loaded.connect(_on_highest_scores_loaded)
	Networking.nearby_scores_loaded.connect(_on_nearby_scores_loaded)
	Networking.score_request_failed.connect(_on_score_request_failed)

func _disconnect_networking() -> void:
	Networking.newest_scores_loaded.disconnect(_on_newest_scores_loaded)
	Networking.highest_scores_loaded.disconnect(_on_highest_scores_loaded)
	Networking.nearby_scores_loaded.disconnect(_on_nearby_scores_loaded)
	Networking.score_request_failed.disconnect(_on_score_request_failed)

func _setup_button_sounds() -> void:
	for child in find_children("", "Button", true, false):
		if child is Button and !child.disabled:
			child.mouse_entered.connect(_on_button_hovered)
			child.pressed.connect(_on_button_clicked)

	var tab_bar := tab_container.get_tab_bar()
	tab_bar.tab_hovered.connect(_on_tab_hovered)
	tab_bar.tab_clicked.connect(_on_tab_clicked)

func _on_newest_scores_loaded(scores: Array) -> void:
	newscore_label.text = _format_score_list(scores, "No recent scores yet.")

func _on_highest_scores_loaded(scores: Array) -> void:
	highscore_label.text = _format_score_list(scores, "No high scores yet.")

func _on_nearby_scores_loaded(payload: Dictionary) -> void:
	myscore_label.text = _format_nearby(payload)

func _on_score_request_failed() -> void:
	var message := "Could not load scores."
	newscore_label.text = message
	highscore_label.text = message
	myscore_label.text = message

func _format_score_list(scores: Array, empty_message: String) -> String:
	if scores.is_empty():
		return empty_message

	var lines: PackedStringArray = []
	for index in scores.size():
		var entry: Dictionary = scores[index]
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		lines.append("%d. %s" % [index + 1, _format_score_entry(entry)])

	return LINE_BREAK.join(lines)


func _format_nearby(payload: Dictionary) -> String:
	var better: Array = payload.get("better", [])
	var worse: Array = payload.get("worse", [])

	var my_entry: Dictionary = {}
	var reference: Variant = payload.get("reference")
	if typeof(reference) == TYPE_DICTIONARY:
		my_entry = reference.duplicate()
	if not UserSettings.player_name.is_empty():
		my_entry["player_name"] = UserSettings.player_name

	var ordered_entries: Array = [
		_nearby_entry_at(better, 0),
		_nearby_entry_at(better, 1),
		my_entry,
		_nearby_entry_at(worse, 1),
		_nearby_entry_at(worse, 0),
	]

	var lines: PackedStringArray = []
	for index in ordered_entries.size():
		var entry: Dictionary = ordered_entries[index]
		if entry.is_empty():
			lines.append("%d. —" % [index + 1])
		else:
			lines.append("%d. %s" % [index + 1, _format_score_entry(entry)])

	return LINE_BREAK.join(lines)

func _nearby_entry_at(scores: Array, index: int) -> Dictionary:
	if index < 0 or index >= scores.size():
		return {}
	var entry: Variant = scores[index]
	if typeof(entry) != TYPE_DICTIONARY:
		return {}
	return entry

func _format_score_entry(entry: Dictionary) -> String:
	var player_name: String = str(entry.get("player_name", "(unnamed)"))
	var total: int = int(entry.get("total", 0))
	var cargo: int = int(entry.get("cargo", 0))
	var money: int = int(entry.get("money", 0))
	var resources: int = int(entry.get("resources", 0))
	return "%s — Total %d (C:%d M:%d R:%d)" % [player_name, total, cargo, money, resources]

func _on_main_menu_pressed() -> void:
	GameManager.return_to_main_menu()
func _on_button_hovered() -> void:
	AudioPlayer.play_ui_button_hover()
func _on_button_clicked() -> void:
	AudioPlayer.play_ui_button_click()
func _on_tab_hovered(_tab: int) -> void:
	AudioPlayer.play_ui_button_hover()
func _on_tab_clicked(_tab: int) -> void:
	AudioPlayer.play_ui_button_click()
