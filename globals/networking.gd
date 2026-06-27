extends HTTPRequest

# Player ID
var client_id: String = OS.get_unique_id()

const PUBLIC_KEY_PATH := "res://PSXstrike_keys.pem"
const HIGHSCORES_BASE_URL := "https://nofunallworkgames.fyi/api/PSXstrike/highscores"
const SCORE_POST_URL := "https://nofunallworkgames.fyi/api/PSXstrike/score"
const SCORE_ENCRYPTED_POST_URL := "https://nofunallworkgames.fyi/api/PSXstrike/score_encrypted"

signal newest_scores_loaded(scores: Array)
signal highest_scores_loaded(scores: Array)
signal nearby_scores_loaded(scores: Array)

@onready var _newest_highscores_request: HTTPRequest = $NewestHighscoresRequest
@onready var _highest_highscores_request: HTTPRequest = $HighestHighscoresRequest
@onready var _nearby_highscores_request: HTTPRequest = $NearbyHighscoresRequest


func _ready() -> void:
	_newest_highscores_request.request_completed.connect(_on_newest_highscores_request_completed)
	_highest_highscores_request.request_completed.connect(_on_highest_highscores_request_completed)
	_nearby_highscores_request.request_completed.connect(_on_nearby_highscores_request_completed)


func _load_public_key_pem() -> String:
	return FileAccess.get_file_as_string(PUBLIC_KEY_PATH).strip_edges()

## TODO Not yet used
func encrypt_data(plain_text: String) -> PackedByteArray:
	var crypto = Crypto.new()
	var key = CryptoKey.new()

	var public_key_pem = _load_public_key_pem()
	if public_key_pem.is_empty():
		return PackedByteArray()

	var error = key.load_from_string(public_key_pem, false)
	if error != OK:
		push_error("Failed to load public key. Error code: " + str(error))
		return PackedByteArray()

	var data_bytes = plain_text.to_utf8_buffer()
	return crypto.encrypt(key, data_bytes)

## TODO Not yet used
func post_data_encrypted(data: PackedByteArray) -> int:
	var headers = ["Content-Type: application/octet-stream"]
	return request_raw(SCORE_ENCRYPTED_POST_URL, headers, HTTPClient.METHOD_POST, data)

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
