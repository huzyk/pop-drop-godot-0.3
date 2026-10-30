extends SceneTree
const Progression = preload("res://scripts/gravity_progression.gd")
const Game = preload("res://scripts/gravity_game.gd")

func _initialize() -> void:
	# Parse the actual game scene code (including the new profile overlay).
	var game = Game.new()
	assert(game != null)
	game.free()
	var profile = Progression.new()
	profile.persist_enabled = false
	var bonuses: Array = []
	var levels: Array = []
	var badges: Array = []
	profile.mission_completed.connect(func(key, value): bonuses.append([key,value]))
	profile.level_reached.connect(func(value): levels.append(value))
	profile.achievement_unlocked.connect(func(id, coins): badges.append([id,coins]))

	assert(profile.level() == 1)
	assert(profile.level_fraction() == 0.0)
	assert(not profile.select_skin("aurora"))
	assert(not profile.select_skin("starlight"))
	var day: String = "2026-10-28"
	for move in range(10):
		profile.record_drop("drop-%d" % move,day)
	assert(profile.total_drops == 10)
	assert(profile.streak == 1)
	assert(profile.daily["drops"] == 10)
	assert(profile.claimed["drops"] == true)
	assert(profile.xp == 80) # Ten drops (+20) and mission (+60)
	assert(profile.unlocked_achievements.get("first_drop",false))
	assert(badges.size() == 1)
	assert(badges[0] == ["first_drop",20])
	profile.record_drop("drop-9",day) # Duplicate event ignored.
	assert(profile.xp == 80)
	profile.record_drop("drop-10",day)
	assert(profile.daily["drops"] == 10) # Mission progress is capped.
	assert(profile.xp == 82)

	for group in range(3):
		profile.record_pop("pop-%d" % group,1,5,600,1,day)
	assert(profile.total_pops == 3)
	assert(profile.daily["pops"] == 3)
	assert(profile.daily["points"] == 1800)
	assert(profile.claimed["pops"] == true)
	assert(profile.claimed["points"] == true)
	assert(bonuses.size() == 3)
	assert(profile.level() == 2)
	assert(not profile.select_skin("aurora"))
	# Two more pops unlock the first cosmetic skin.
	profile.record_pop("pop-3",1,5,600,1,day)
	profile.record_pop("pop-4",1,5,600,1,day)
	assert(profile.level() == 3)
	assert(levels.size() >= 2)
	assert(profile.select_skin("aurora"))
	assert(profile.skin == "aurora")
	assert(not profile.select_skin("starlight"))
	profile.record_round("round-one")
	profile.record_round("round-one") # Idempotent
	assert(profile.total_rounds == 1)

	# Displaying missions on another date must not award a streak day.
	profile.ensure_day("2026-10-29")
	assert(profile.daily["drops"] == 0)
	assert(not profile.claimed["drops"])
	assert(profile.streak == 1)
	profile.record_drop("tomorrow-drop","2026-10-29")
	assert(profile.streak == 2)
	assert(profile.last_play_day == "2026-10-29")
	profile.record_drop("late-drop","2026-10-31")
	assert(profile.streak == 1) # A missed day resets the counter.
	assert(profile.total_drops == 13)
	assert(profile.unlocked_achievements.get("pop_1",false))
	assert(profile.achievement_unlocked_count() >= 2)
	# Achievements are permanent, one-time payouts, independent from daily XP.
	profile.record_pop("chain-4",1,10,2000,4,"2026-10-31")
	assert(profile.unlocked_achievements.get("combo_2",false))
	assert(profile.unlocked_achievements.get("combo_4",false))
	var badge_total: int = badges.size()
	profile.record_pop("chain-4",1,10,2000,4,"2026-10-31")
	assert(badges.size() == badge_total)
	assert(profile.achievement_progress("chain_4") == 4)
	assert(Progression.ACHIEVEMENTS.size() == 12)
	print("PASS: Gravity XP, mission once-only rewards, date rollover, streak and skins")
	quit()
