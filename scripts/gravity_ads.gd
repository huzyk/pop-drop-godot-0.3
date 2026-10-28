extends Node
## Reward safety contract. Fails closed until a real, consent-aware SDK
## adapter is attached. No mock rewards in release/gameplay builds.
signal reward_earned(transaction: int)
signal rewarded_unavailable
var provider = null
var next_transaction: int = 0
var pending_transaction: int = -1
var last_interstitial_ms: int = -99999999

func _ready() -> void:
	# The optional provider script is loaded only when its native Godot
	# plugin is installed, enabled, and explicitly opted into in settings.
	if not bool(ProjectSettings.get_setting("pop_drop/ads/enable_admob", false)):
		return
	if not FileAccess.file_exists("res://addons/admob/plugin.cfg"):
		push_warning("AdMob enabled but Poing Studios addon is missing")
		return
	var script: Script = load("res://scripts/poing_admob_provider.gd")
	if script == null:
		return
	var adapter: Node = script.new()
	add_child(adapter)
	attach_provider(adapter)

func attach_provider(adapter: Node) -> void:
	if provider != null:
		if provider.reward_earned.is_connected(_confirm_reward):
			provider.reward_earned.disconnect(_confirm_reward)
		if provider.rewarded_finished.is_connected(cancel_pending):
			provider.rewarded_finished.disconnect(cancel_pending)
	provider = adapter
	if provider != null:
		provider.reward_earned.connect(_confirm_reward)
		provider.rewarded_finished.connect(cancel_pending)

func rewarded_ready() -> bool:
	return provider != null and pending_transaction < 0 and provider.is_rewarded_ready()

func request_rewarded() -> bool:
	if not rewarded_ready():
		rewarded_unavailable.emit()
		return false
	next_transaction += 1
	pending_transaction = next_transaction
	provider.show_rewarded(next_transaction)
	return true

func _confirm_reward(transaction: int) -> void:
	if transaction != pending_transaction or pending_transaction < 0:
		return
	pending_transaction = -1
	reward_earned.emit(transaction)

func cancel_pending(transaction: int) -> void:
	if pending_transaction == transaction:
		pending_transaction = -1

func request_interstitial() -> bool:
	if provider == null or not provider.is_interstitial_ready():
		return false
	var now: int = Time.get_ticks_msec()
	if now - last_interstitial_ms < 90000:
		return false
	last_interstitial_ms = now
	provider.show_interstitial()
	return true

func show_privacy_options() -> void:
	if provider != null:
		provider.show_privacy_options()
