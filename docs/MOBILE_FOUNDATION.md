# Mobile foundation — Gravity 0.4 alpha

This branch prepares the mobile product; it is not a released, fully configured monetized application.

## Implemented

- Stable checkpoint after initial board generation and after every completed drop/rotation.
- Restores board, tray, score, moves, lives, revives, and round identity after re-opening.
- Saves only stable `drop`/`over` states, never a half-finished animation.
- Versioned checkpoint validator with temporary-file write then rename.
- GDPR-conscious anonymous analytics **off by default**. A visible **DATA** menu switches analytics on/off and clears the local tracking identity/event log.
- Consented events: `session_start`, `game_start`, `piece_drop`, `board_rotate`, `pop_triggered`, `life_lost`, `game_over`, and `ad_reward_earned`.
- Locally buffered JSONL events in `user://gravity_events.jsonl`; optional HTTPS delivery to PostHog EU/US when a project key is configured.
- AdMob integration is **opt-in and disabled by default**. Optional Poing Studios Godot AdMob 5.x provider for UMP, rewarded and interstitial.
- No free test revive. One rewarded revive max per run; only a valid matching reward-earned callback can give a life. Interstitials are attempted only between rounds, after every third round, at most once per 90 seconds. Missing SDK/ad/consent means **no ad**, not a fake reward.

## Configure PostHog

1. Create your PostHog project and obtain the **public project API key** (not a personal secret token).
2. In `project.godot`: under `[pop_drop]`, set `analytics/posthog_key="phc_..."`, `analytics/region="eu"` for EU. No network tracking without a key.
3. In-game use **DATA → GAME ANALYTICS ON**. Default is off. Events are logged locally with consent even if the project key is empty.
4. Dashboard: funnels from `game_start` to `game_over`; retention cohorts on `session_start`; `ad_reward_earned` by run; board occupancy on drops.

**Data limitations:** Clearing local events and identity does not automatically delete previously delivered PostHog records; a documented server-side deletion request flow and privacy policy are required before public launch. A pseudonymous ID can still be personal data under GDPR.

## Configure Android AdMob (not yet packaged)

1. Install **Poing Studios AdMob plugin v5.x** in Godot (AssetLib or official GitHub), enable plugin, install its native Android dependencies. Requires Godot v4.5+; test with the target engine version. The plugin file `res://addons/admob/plugin.cfg` must exist.
2. Register the application in AdMob, add an Android AdMob App ID to the plugin/Android export configuration, and create an **EOG/UK consent message** in AdMob Privacy & messaging (UMP). Verify your CMP/privacy policy.
3. Turn on Android `INTERNET` permission in export settings; use an Android debug build and Google's test ad units only.
4. In `project.godot` enable `ads/enable_admob=true`. Leave units empty for **Google's Android test IDs only in debug builds**. The provider has separate test defaults for rewarded and interstitial. In release builds both must use real IDs:
   - `ads/rewarded_unit="ca-app-pub-.../..."`
   - `ads/interstitial_unit="ca-app-pub-.../..."`
5. Test UMP required/obtained/rejected flow on a device; test return from background; watch a full rewarded ad; dismiss without earning; offline and failed loads. **Never use a real ad ID for automated testing or on your own device without appropriate test-device configuration.**
6. Use **DATA → AD PRIVACY OPTIONS** to reopen UMP options. UMP and analytics choices are distinct.

The provider script `scripts/poing_admob_provider.gd` is dynamically loaded only if enabled *and* the plugin exists. With AdMob disabled, the game works offline and the rescue button is unavailable.

## Validation

```bash
godot --headless --path . --script res://tests/test_gravity_session.gd
godot --headless --path . --script res://tests/test_gravity_ads.gd
godot --headless --path . --script res://tests/test_gravity_rules.gd
godot --path .
```

The tests cover checkpoint integrity and rewarded-callback double delivery, but **have not yet run inside Godot in the author's environment**. Final engine import, scene smoke test, actual AdMob v5.x native SDK/UMP, Android export and real-device performance remain blockers before a release candidate.

## Next product milestones

- Game feel: sound, haptics, improved bead effects, shorter/clearer tutorial, accessibility settings.
- Retention: daily goals, persistent XP, cosmetic unlockables and cohort experiments.
- Ad optimization: real impression-level revenue, frequency cap experiments, rewarded opt-in conversion, no in-game interruptions.
- Data operations: crash tracking, consented secure analytics, deletion endpoint and privacy policy.
- Beta QA: diverse Android models, varying refresh rate, calls/backgrounding, 30–50 human testers, D1/D7 funnels.

Do not represent this alpha as app-store-ready.
