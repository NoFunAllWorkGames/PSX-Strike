extends CanvasLayer

@onready var highscore_grid: GridContainer = $Overlay/CenterContainer/ScorePanel/VBoxContainer/TabContainer/Highscore
@onready var newscore_grid: GridContainer = $Overlay/CenterContainer/ScorePanel/VBoxContainer/TabContainer/Newscore
@onready var myscore_grid: GridContainer = $Overlay/CenterContainer/ScorePanel/VBoxContainer/TabContainer/Myscore
@onready var main_menu_button: Button = $Overlay/CenterContainer/ScorePanel/VBoxContainer/MainMenuButton
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
	_populate_score_grid(newscore_grid, scores, "No recent scores yet.")

func _on_highest_scores_loaded(scores: Array) -> void:
	_populate_score_grid(highscore_grid, scores, "No high scores yet.")

func _on_nearby_scores_loaded(payload: Dictionary) -> void:
	_populate_nearby_grid(myscore_grid, payload)

func _on_score_request_failed() -> void:
	_show_error(highscore_grid)
	_show_error(newscore_grid)
	_show_error(myscore_grid)

func _populate_score_grid(grid: GridContainer, scores: Array, empty_message: String) -> void:
	_clear_data_rows(grid)

	if scores.is_empty():
		_add_grid_row(grid, "—", empty_message, "—", "—", "—", "—")
		return

	for index in scores.size():
		var entry: Variant = scores[index]
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		_add_grid_row(
			grid,
			str(index + 1),
			str(entry.get("player_name", "(unnamed)")),
			str(int(entry.get("cargo", 0))),
			str(int(entry.get("money", 0))),
			str(int(entry.get("resources", 0))),
			str(int(entry.get("total", 0))),
		)

func _populate_nearby_grid(grid: GridContainer, payload: Dictionary) -> void:
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

	_clear_data_rows(grid)

	for index in ordered_entries.size():
		var entry: Dictionary = ordered_entries[index]
		var rank := str(index + 1)
		if entry.is_empty():
			_add_grid_row(grid, rank, "—", "—", "—", "—", "—")
		else:
			_add_grid_row(
				grid,
				rank,
				str(entry.get("player_name", "(unnamed)")),
				str(int(entry.get("cargo", 0))),
				str(int(entry.get("money", 0))),
				str(int(entry.get("resources", 0))),
				str(int(entry.get("total", 0))),
			)

func _nearby_entry_at(scores: Array, index: int) -> Dictionary:
	if index < 0 or index >= scores.size():
		return {}
	var entry: Variant = scores[index]
	if typeof(entry) != TYPE_DICTIONARY:
		return {}
	return entry

func _show_error(grid: GridContainer) -> void:
	_clear_data_rows(grid)
	_add_grid_row(grid, "—", "Could not load scores.", "—", "—", "—", "—")

func _clear_data_rows(grid: GridContainer) -> void:
	# clear all children except the headers
	for index in range(grid.get_child_count() - 1, grid.columns - 1, -1):
		grid.get_child(index).queue_free()

func _add_grid_row(
	grid: GridContainer,
	rank: String,
	player_name: String,
	cargo: String,
	money: String,
	resources: String,
	total: String,
) -> void:
	grid.add_child(_cell_from_header(grid, "RankHeader", rank))
	grid.add_child(_cell_from_header(grid, "NameHeader", player_name))
	grid.add_child(_cell_from_header(grid, "CargoHeader", cargo))
	grid.add_child(_cell_from_header(grid, "MoneyHeader", money))
	grid.add_child(_cell_from_header(grid, "ResourcesHeader", resources))
	grid.add_child(_cell_from_header(grid, "TotalHeader", total))

func _cell_from_header(grid: GridContainer, header_name: String, text: String) -> Label:
	var label: Label = grid.get_node(header_name).duplicate()
	label.text = text
	return label

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
