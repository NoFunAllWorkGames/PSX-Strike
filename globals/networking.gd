extends HTTPRequest

# Player ID
var client_id: String = OS.get_unique_id()

const PUBLIC_KEY_PATH := "res://projectstrike_keys.pem"
const HIGHSCORES_BASE_URL := "https://nofunallworkgames.fyi/api/projectstrike/highscores"
const SCORE_POST_URL := "https://nofunallworkgames.fyi/api/projectstrike/score"
const SCORE_ENCRYPTED_POST_URL := "https://nofunallworkgames.fyi/api/projectstrike/score_encrypted"

signal newest_scores_loaded(scores: Array)
signal highest_scores_loaded(scores: Array)
signal nearby_scores_loaded(payload: Dictionary)
signal highscores_request_failed(endpoint: String, response_code: int)

var _public_key_pem: String = ""
var _get_requests: Dictionary = {}


func _ready() -> void:
	request_completed.connect(_on_post_completed)
	for endpoint in ["newest", "highest", "nearby"]:
		var http_request := HTTPRequest.new()
		http_request.request_completed.connect(
			func(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
				_on_highscores_get_completed(endpoint, result, response_code, headers, body)
		)
		add_child(http_request)
		_get_requests[endpoint] = http_request


func _load_public_key_pem() -> String:
	if not _public_key_pem.is_empty():
		return _public_key_pem
	if not FileAccess.file_exists(PUBLIC_KEY_PATH):
		push_error("Public key file not found: " + PUBLIC_KEY_PATH)
		return ""
	_public_key_pem = FileAccess.get_file_as_string(PUBLIC_KEY_PATH).strip_edges()
	return _public_key_pem


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


func post_data_encrypted(data: PackedByteArray) -> int:
	var headers = ["Content-Type: application/octet-stream"]
	return request_raw(SCORE_ENCRYPTED_POST_URL, headers, HTTPClient.METHOD_POST, data)


func post_data_json(data: Dictionary) -> int:
	var headers = ["Content-Type: application/json"]
	return request(SCORE_POST_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(data))


func post_scores() -> void:
	var data = {
		"client_id": client_id,
		"player_name": UserSettings.player_name,
		"timestamp": Time.get_unix_time_from_system(),
		"cargo": GameManager.cargo.cargo_amount,
		"money": GameManager.station_resources.money_amount,
		"resources": GameManager.station_resources.resources_amount,
	}
	post_data_json(data)


func fetch_all_highscores() -> void:
	fetch_highscores_newest()
	fetch_highscores_highest()
	fetch_highscores_nearby()


func fetch_highscores_newest() -> void:
	_request_highscores_get("newest", HIGHSCORES_BASE_URL + "/newest")


func fetch_highscores_highest() -> void:
	_request_highscores_get("highest", HIGHSCORES_BASE_URL + "/highest")


func fetch_highscores_nearby() -> void:
	var url: String = HIGHSCORES_BASE_URL + "/nearby?client_id=" + client_id.uri_encode()
	_request_highscores_get("nearby", url)


func _request_highscores_get(endpoint: String, url: String) -> void:
	var http_request: HTTPRequest = _get_requests.get(endpoint)
	if http_request == null:
		push_error("Unknown highscores endpoint: " + endpoint)
		return
	if http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	var error := http_request.request(url)
	if error != OK:
		highscores_request_failed.emit(endpoint, -1)


func _on_highscores_get_completed(
	endpoint: String,
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		highscores_request_failed.emit(endpoint, response_code)
		return

	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		highscores_request_failed.emit(endpoint, response_code)
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		highscores_request_failed.emit(endpoint, response_code)
		return

	match endpoint:
		"newest":
			newest_scores_loaded.emit(data.get("scores", []))
		"highest":
			highest_scores_loaded.emit(data.get("scores", []))
		"nearby":
			nearby_scores_loaded.emit(data)


func _on_post_completed(
	_result: int,
	_response_code: int,
	_headers: PackedStringArray,
	_body: PackedByteArray,
) -> void:
	pass
