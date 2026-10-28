extends Node
## Privacy-first event tracking: disabled by default. No advertising IDs.
## Optional PostHog destination configured in Project Settings, not in source.
const PREFS := "user://gravity_analytics_privacy.json"
const LOCAL_LOG := "user://gravity_events.jsonl"
const MAX_PENDING := 80
var opted_in: bool = false
var anonymous_id: String = ""
var session_id: String = ""
var pending: Array = []
var sending: bool = false
var http: HTTPRequest
var project_key: String = ""
var host: String = "https://eu.i.posthog.com"

func _ready() -> void:
	session_id = _id()
	var value: Variant = null
	if FileAccess.file_exists(PREFS):
		value = JSON.parse_string(FileAccess.get_file_as_string(PREFS))
	if value is Dictionary:
		opted_in = bool(value.get("analytics", false))
		anonymous_id = str(value.get("anonymous_id", ""))
	if opted_in and anonymous_id.is_empty():
		anonymous_id = _id()
		_store_prefs()
	project_key = str(ProjectSettings.get_setting("pop_drop/analytics/posthog_key", ""))
	if str(ProjectSettings.get_setting("pop_drop/analytics/region", "eu")) == "us":
		host = "https://us.i.posthog.com"
	http = HTTPRequest.new()
	http.timeout = 8.0
	add_child(http)
	http.request_completed.connect(_request_done)

func set_opted_in(allow: bool) -> void:
	opted_in = allow
	if allow:
		if anonymous_id.is_empty():
			anonymous_id = _id()
	else:
		anonymous_id = ""
		pending.clear()
		if FileAccess.file_exists(LOCAL_LOG):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(LOCAL_LOG))
	_store_prefs()

func erase_events_and_identity() -> void:
	set_opted_in(false)
	if FileAccess.file_exists(PREFS):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PREFS))
	# A pending HTTP request cannot be recalled. Cancel it if it exists.
	if http != null:
		http.cancel_request()
	sending = false

func track(event_name: String, properties: Dictionary = {}) -> void:
	if not opted_in:
		return
	var data: Dictionary = properties.duplicate(true)
	data["session_id"] = session_id
	data["platform"] = OS.get_name()
	data["game_version"] = str(ProjectSettings.get_setting("application/config/version", "prototype"))
	var item: Dictionary = {
		"api_key": project_key,
		"event": event_name,
		"distinct_id": anonymous_id,
		"timestamp": Time.get_datetime_string_from_system(true, false),
		"properties": data
	}
	_append_local(item)
	if project_key.is_empty():
		return
	pending.append(item)
	if pending.size() > MAX_PENDING:
		pending.pop_front()
	_send_next()

func _send_next() -> void:
	if sending or not opted_in or pending.is_empty() or project_key.is_empty():
		return
	sending = true
	var error: Error = http.request(
		host + "/capture/",
		PackedStringArray(["Content-Type: application/json"]),
		HTTPClient.METHOD_POST,
		JSON.stringify(pending[0])
	)
	if error != OK:
		sending = false
		pending.pop_front()

func _request_done(_result: int, _code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	sending = false
	if not pending.is_empty():
		pending.pop_front()
	_send_next()

func _append_local(item: Dictionary) -> void:
	if FileAccess.file_exists(LOCAL_LOG):
		var size: int = FileAccess.get_file_as_bytes(LOCAL_LOG).size()
		if size > 1024 * 1024:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(LOCAL_LOG))
	var mode: int = FileAccess.READ_WRITE if FileAccess.file_exists(LOCAL_LOG) else FileAccess.WRITE
	var file: FileAccess = FileAccess.open(LOCAL_LOG, mode)
	if file != null:
		file.seek_end()
		file.store_line(JSON.stringify(item))
		file.close()

func _store_prefs() -> void:
	var file: FileAccess = FileAccess.open(PREFS, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({"analytics": opted_in, "anonymous_id": anonymous_id}))
		file.close()

func _id() -> String:
	return Crypto.new().generate_random_bytes(16).hex_encode()
