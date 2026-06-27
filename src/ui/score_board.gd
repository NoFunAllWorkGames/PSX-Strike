extends CanvasLayer

@onready var highscore_grid: GridContainer = $Overlay/CenterContainer/ScorePanel/VBoxContainer/TabContainer/Highscores/Highscore
@onready var recentscore_grid: GridContainer = $"Overlay/CenterContainer/ScorePanel/VBoxContainer/TabContainer/Recent Scores/Recentscore"
@onready var myscore_grid: GridContainer = $"Overlay/CenterContainer/ScorePanel/VBoxContainer/TabContainer/My Scores/Myscore"
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

func _disconnect_networking() -> void:
	Networking.newest_scores_loaded.disconnect(_on_newest_scores_loaded)
	Networking.highest_scores_loaded.disconnect(_on_highest_scores_loaded)
	Networking.nearby_scores_loaded.disconnect(_on_nearby_scores_loaded)

func _setup_button_sounds() -> void:
	for child in find_children("", "Button", true, false):
		if child is Button and !child.disabled:
			child.mouse_entered.connect(_on_button_hovered)
			child.pressed.connect(_on_button_clicked)

	var tab_bar := tab_container.get_tab_bar()
	tab_bar.tab_hovered.connect(_on_tab_hovered)
	tab_bar.tab_clicked.connect(_on_tab_clicked)

func _on_newest_scores_loaded(scores: Array) -> void:
	_populate_recent_grid(recentscore_grid, scores)

func _on_highest_scores_loaded(scores: Array) -> void:
	_populate_score_grid(highscore_grid, scores, "Rank")

func _on_nearby_scores_loaded(scores: Array) -> void:
	myscore_grid.get_node("RankHeader").text = "Compared"
	_clear_data_rows(myscore_grid)

	for index in scores.size():
		var entry: Dictionary = scores[index]
		_add_grid_row(
			myscore_grid,
			_similar_compared_label(index),
			str(entry.get("player_name", "(unnamed)")),
			str(int(entry.get("cargo", 0))),
			str(int(entry.get("money", 0))),
			str(int(entry.get("resources", 0))),
			str(int(entry.get("total", 0))),
		)

func _recent_age_label(index: int, count: int) -> String:
	if index == 0:
		return "Older"
	if index == count - 1:
		return "This run"
	return ""

func _similar_compared_label(index: int) -> String:
	if index < 2:
		return "Better"
	if index == 2:
		return "This run"
	if index > 2:
		return "Worse"
	return ""

func _populate_recent_grid(grid: GridContainer, scores: Array) -> void:
	grid.get_node("RankHeader").text = "Age"
	_clear_data_rows(grid)

	for index in scores.size():
		var entry: Dictionary = scores[index]
		_add_grid_row(
			grid,
			_recent_age_label(index, scores.size()),
			str(entry.get("player_name", "(unnamed)")),
			str(int(entry.get("cargo", 0))),
			str(int(entry.get("money", 0))),
			str(int(entry.get("resources", 0))),
			str(int(entry.get("total", 0))),
		)

func _populate_score_grid(
	grid: GridContainer,
	scores: Array,
	first_column_header: String = "Rank",
) -> void:
	grid.get_node("RankHeader").text = first_column_header
	_clear_data_rows(grid)

	for index in scores.size():
		var entry: Dictionary = scores[index]
		_add_grid_row(
			grid,
			str(index + 1),
			str(entry.get("player_name", "(unnamed)")),
			str(int(entry.get("cargo", 0))),
			str(int(entry.get("money", 0))),
			str(int(entry.get("resources", 0))),
			str(int(entry.get("total", 0))),
		)

func _clear_data_rows(grid: GridContainer) -> void:
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
