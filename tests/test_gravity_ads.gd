extends SceneTree
const Ads = preload("res://scripts/gravity_ads.gd")

class FakeReward:
	extends Node
	signal reward_earned(transaction: int)
	signal rewarded_finished(transaction: int)
	var last: int = -1
	func is_rewarded_ready() -> bool:
		return true
	func show_rewarded(tx: int) -> void:
		last = tx
	func is_interstitial_ready() -> bool:
		return true
	func show_interstitial() -> void:
		pass
	func show_privacy_options() -> void:
		pass

func _initialize() -> void:
	# Godot's Android editor eagerly parses *all* .gd sources, even when not used.
	# Optional SDK adapters must be kept as templates until the addon is installed.
	assert(not ResourceLoader.exists("res://scripts/poing_admob_provider.gd"))
	assert(FileAccess.file_exists("res://docs/integrations/poing_admob_provider.gd.txt"))
	var manager = Ads.new()
	root.add_child(manager)
	assert(not manager.rewarded_ready())
	assert(not manager.request_rewarded())
	assert(manager.pending_transaction == -1)
	assert(not manager.request_interstitial())
	var fake = FakeReward.new()
	root.add_child(fake)
	manager.attach_provider(fake)
	var rewarded: Array = []
	manager.reward_earned.connect(func(tx): rewarded.append(tx))
	assert(manager.request_rewarded())
	assert(not manager.request_rewarded()) # One pending reward at a time.
	assert(rewarded.is_empty()) # Clicking is NOT earning.
	fake.reward_earned.emit(fake.last + 2) # Wrong transaction ignored.
	assert(rewarded.is_empty())
	fake.reward_earned.emit(fake.last)
	fake.reward_earned.emit(fake.last) # Duplicate ignored.
	assert(rewarded.size() == 1)
	fake.rewarded_finished.emit(fake.last)
	assert(manager.pending_transaction == -1)
	manager.free()
	fake.free()
	print("PASS: Reward granted once, only for correct SDK transaction")
	quit()
