extends HTTPRequest

# Player ID
var client_id: String = OS.get_unique_id()

const PUBLIC_KEY_PATH := "res://projectstrike_keys.pem"

var _public_key_pem: String = ""

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

	# Convert the input string to a byte array
	var data_bytes = plain_text.to_utf8_buffer()

	# Encrypt the data using the public key
	var encrypted_bytes = crypto.encrypt(key, data_bytes)

	return encrypted_bytes

func post_data_encrypted(data: PackedByteArray):
	var url = "https://nofunallworkgames.fyi/api/projectstrike/score_encrypted"
	var headers = ["Content-Type: application/octet-stream"]

	var error = request_raw(url, headers, HTTPClient.METHOD_POST, data)

	if error != OK:
		print("Error initiating request: ", error)

	return error

func post_data_json(data: Dictionary):
	var url = "https://nofunallworkgames.fyi/api/projectstrike/score"
	var headers = ["Content-Type: application/json"]

	var error = request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))

	if error != OK:
		print("Error initiating request: ", error)

	return error

func post_scores() -> void:
	var data = {
		"client_id": OS.get_unique_id(),
		"player_name": UserSettings.player_name,
		"timestamp": Time.get_unix_time_from_system(),
		"cargo": GameManager.cargo.cargo_amount,
		"money": GameManager.station_resources.money_amount,
		"resources": GameManager.station_resources.resources_amount
	}
	post_data_json(data)
