extends SceneTree
## Opt-in only, no fabricated remote analytics or persistent identifier after erase.
const Telemetry = preload("res://scripts/gravity_telemetry.gd")

func _initialize() -> void:
	var tracker = Telemetry.new()
	root.add_child(tracker)
	tracker.set_opted_in(false)
	assert(not tracker.opted_in)
	assert(tracker.anonymous_id.is_empty())
	tracker.track("never_record",{"message":"no consent"})
	assert(tracker.pending.is_empty())
	assert(not FileAccess.file_exists(Telemetry.LOCAL_LOG))
	tracker.set_opted_in(true)
	assert(tracker.opted_in)
	assert(not tracker.anonymous_id.is_empty())
	tracker.track("consented_test",{"screen":"privacy"})
	assert(FileAccess.file_exists(Telemetry.LOCAL_LOG))
	# Without the configured API key this is stored locally, not sent to PostHog.
	assert(tracker.project_key.is_empty())
	assert(tracker.pending.is_empty())
	tracker.erase_events_and_identity()
	assert(not tracker.opted_in)
	assert(tracker.anonymous_id.is_empty())
	assert(tracker.pending.is_empty())
	assert(not FileAccess.file_exists(Telemetry.PREFS))
	assert(not FileAccess.file_exists(Telemetry.LOCAL_LOG))
	tracker.free()
	# Simulate a slow in-flight request while the bounded queue overflows.
	# No network: sending=true prevents track() from dispatching anything.
	tracker = Telemetry.new()
	tracker.opted_in = true
	tracker.project_key = "test-only"
	tracker.sending = true
	tracker.pending = [{"event":"inflight"}]
	for i in range(Telemetry.MAX_PENDING+5):
		tracker.track("queued_%d" % i)
	assert(tracker.pending.size() == Telemetry.MAX_PENDING)
	assert(tracker.pending[0]["event"] == "inflight")
	assert(tracker.pending[-1]["event"] == "queued_%d" % (Telemetry.MAX_PENDING+4))
	tracker.erase_events_and_identity()
	tracker.free()
	print("PASS: analytics opt-out, local-only draft, erase and disabled network capture")
	quit()

