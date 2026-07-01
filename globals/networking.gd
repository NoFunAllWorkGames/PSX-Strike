extends HTTPRequest

const WEB_CLIENT_ID_PATH := "user://web_client_id.txt"

var client_id: String = ""

const PUBLIC_KEY_PATH := "res://PSXstrike_keys.pem"
const HIGHSCORES_BASE_URL := "https://nofunallworkgames.fyi/api/PSXstrike/highscores"
const SCORE_POST_URL := "https://nofunallworkgames.fyi/api/PSXstrike/score"

signal newest_scores_loaded(scores: Array)
signal highest_scores_loaded(scores: Array)
signal nearby_scores_loaded(scores: Array)

@onready var _newest_highscores_request: HTTPRequest = $NewestHighscoresRequest
@onready var _highest_highscores_request: HTTPRequest = $HighestHighscoresRequest
@onready var _nearby_highscores_request: HTTPRequest = $NearbyHighscoresRequest


func _ready() -> void:
	client_id = _resolve_client_id()
	_newest_highscores_request.request_completed.connect(_on_newest_highscores_request_completed)
	_highest_highscores_request.request_completed.connect(_on_highest_highscores_request_completed)
	_nearby_highscores_request.request_completed.connect(_on_nearby_highscores_request_completed)

static func is_web() -> bool:
	return OS.has_feature("web")


func _load_public_key_pem() -> String:
	return FileAccess.get_file_as_string(PUBLIC_KEY_PATH).strip_edges()


func _resolve_client_id() -> String:
	if is_web():
		# Check if the client id file exists
		if FileAccess.file_exists(WEB_CLIENT_ID_PATH):
			return FileAccess.get_file_as_string(WEB_CLIENT_ID_PATH).strip_edges()

		# Create a new UUID client id
		var id := _generate_uuid_v4()
		var file := FileAccess.open(WEB_CLIENT_ID_PATH, FileAccess.WRITE)
		if file:
			file.store_string(id)
		return id

	if not is_web():
		return OS.get_unique_id()

	return "Error"

func _generate_uuid_v4() -> String:
	var bytes := Crypto.new().generate_random_bytes(16)
	bytes[6] = (bytes[6] & 0x0f) | 0x40
	bytes[8] = (bytes[8] & 0x3f) | 0x80
	return "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x" % [
		bytes[0], bytes[1], bytes[2], bytes[3],
		bytes[4], bytes[5],
		bytes[6], bytes[7],
		bytes[8], bytes[9],
		bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15],
	]

func post_scores() -> void:
	var data = {
		"client_id": client_id,
		"player_name": UserSettings.player_name,
		"timestamp": Time.get_unix_time_from_system(),
		"cargo": int(GameManager.cargo.cargo_amount),
		"money": int(GameManager.station_resources.money_amount),
		"resources": int(GameManager.station_resources.resources_amount),
	}
	var headers = ["Content-Type: application/json"]
	return request(SCORE_POST_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(data))

## used in Score_Board.tscn
func fetch_all_highscores() -> void:
	fetch_highscores_newest()
	fetch_highscores_highest()
	fetch_highscores_nearby()

func fetch_highscores_newest() -> void:
	if _newest_highscores_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	_newest_highscores_request.request(HIGHSCORES_BASE_URL + "/newest")

func fetch_highscores_highest() -> void:
	if _highest_highscores_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	_highest_highscores_request.request(HIGHSCORES_BASE_URL + "/highest")

func fetch_highscores_nearby() -> void:
	if _nearby_highscores_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	var url: String = HIGHSCORES_BASE_URL + "/nearby?client_id=" + client_id.uri_encode()
	_nearby_highscores_request.request(url)

func _on_newest_highscores_request_completed(
	_result: int,
	_response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
) -> void:
	var data: Variant = _read_highscores_response(body)
	newest_scores_loaded.emit(data.get("scores", []))

func _on_highest_highscores_request_completed(
	_result: int,
	_response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
) -> void:
	var data: Variant = _read_highscores_response(body)
	highest_scores_loaded.emit(data.get("scores", []))

func _on_nearby_highscores_request_completed(
	_result: int,
	_response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
) -> void:
	var data: Variant = _read_highscores_response(body)
	nearby_scores_loaded.emit(data.get("scores", []))

func _read_highscores_response(body: PackedByteArray) -> Variant:
	var json := JSON.new()
	json.parse(body.get_string_from_utf8())
	return json.data
