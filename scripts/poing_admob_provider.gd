extends Node
## Optional Poing Studios AdMob 5.x provider. Requires installed/enabled addon.
## Do not preload this file from gameplay: its global classes exist only with addon.
signal reward_earned(transaction: int)
signal rewarded_finished(transaction: int)
var _rewarded_ad = null
var _interstitial_ad = null
var _active_transaction: int = -1
var _initialized: bool = false
var _rewarded_loading: bool = false
var _interstitial_loading: bool = false
var _rewarded_callback = null
var _interstitial_callback = null
var _reward_listener = null

func _ready() -> void:
	# Update UMP on every launch; never load ads before the choice is resolved.
	UserMessagingPlatform.consent_information.update(
		ConsentRequestParameters.new(), _on_consent_ready, _on_consent_failed
	)

func _on_consent_failed(_error) -> void:
	_try_start_ads() # Only if a previously valid stored consent exists.

func _on_consent_ready() -> void:
	var info = UserMessagingPlatform.consent_information
	if info.get_consent_status() == info.ConsentStatus.REQUIRED:
		UserMessagingPlatform.load_consent_form(_on_consent_form_loaded, _on_consent_failed)
	else:
		_try_start_ads()

func _on_consent_form_loaded(form) -> void:
	form.show(_on_consent_form_closed)

func _on_consent_form_closed(_error) -> void:
	_try_start_ads()

func _try_start_ads() -> void:
	var info = UserMessagingPlatform.consent_information
	var status: int = info.get_consent_status()
	if status != info.ConsentStatus.OBTAINED and status != info.ConsentStatus.NOT_REQUIRED:
		return
	if _initialized:
		return
	_initialized = true
	MobileAds.initialize()
	_load_rewarded()
	_load_interstitial()

func show_privacy_options() -> void:
	UserMessagingPlatform.show_privacy_options_form(func(_error):
		# The SDK determines ad eligibility and consent on subsequent requests.
		pass
	)

func is_rewarded_ready() -> bool:
	return _rewarded_ad != null and _active_transaction < 0

func show_rewarded(transaction: int) -> void:
	if not is_rewarded_ready():
		rewarded_finished.emit(transaction)
		return
	_active_transaction = transaction
	_reward_listener = OnUserEarnedRewardListener.new()
	_reward_listener.on_user_earned_reward = func(_rewarded_item):
		if _active_transaction == transaction:
			reward_earned.emit(transaction)
	_rewarded_ad.show(_reward_listener)

func _load_rewarded() -> void:
	if not _initialized or _rewarded_loading:
		return
	_rewarded_loading = true
	if _rewarded_ad != null:
		_rewarded_ad.destroy()
		_rewarded_ad = null
	var unit: String = str(ProjectSettings.get_setting("pop_drop/ads/rewarded_unit", ""))
	if unit.is_empty() and OS.is_debug_build():
		unit = "ca-app-pub-3940256099942544/5224354917"
	if unit.is_empty():
		_rewarded_loading = false
		return
	var callback = RewardedAdLoadCallback.new()
	callback.on_ad_failed_to_load = func(_error):
		_rewarded_loading = false
	callback.on_ad_loaded = func(ad):
		_rewarded_loading = false
		_rewarded_ad = ad
		_rewarded_callback = FullScreenContentCallback.new()
		_rewarded_callback.on_ad_dismissed_full_screen_content = func():
			_finish_rewarded()
		_rewarded_callback.on_ad_failed_to_show_full_screen_content = func(_error):
			_finish_rewarded()
		ad.full_screen_content_callback = _rewarded_callback
	RewardedAdLoader.new().load(unit, AdRequest.new(), callback)

func _finish_rewarded() -> void:
	var tx: int = _active_transaction
	_active_transaction = -1
	_reward_listener = null
	if tx >= 0:
		rewarded_finished.emit(tx)
	if _rewarded_ad != null:
		_rewarded_ad.destroy()
		_rewarded_ad = null
	_load_rewarded()

func is_interstitial_ready() -> bool:
	return _interstitial_ad != null

func show_interstitial() -> void:
	if _interstitial_ad != null:
		_interstitial_ad.show()

func _load_interstitial() -> void:
	if not _initialized or _interstitial_loading:
		return
	_interstitial_loading = true
	if _interstitial_ad != null:
		_interstitial_ad.destroy()
		_interstitial_ad = null
	var unit: String = str(ProjectSettings.get_setting("pop_drop/ads/interstitial_unit", ""))
	if unit.is_empty() and OS.is_debug_build():
		unit = "ca-app-pub-3940256099942544/1033173712"
	if unit.is_empty():
		_interstitial_loading = false
		return
	var callback = InterstitialAdLoadCallback.new()
	callback.on_ad_failed_to_load = func(_error):
		_interstitial_loading = false
	callback.on_ad_loaded = func(ad):
		_interstitial_loading = false
		_interstitial_ad = ad
		_interstitial_callback = FullScreenContentCallback.new()
		_interstitial_callback.on_ad_dismissed_full_screen_content = func():
			_finish_interstitial()
		_interstitial_callback.on_ad_failed_to_show_full_screen_content = func(_error):
			_finish_interstitial()
		ad.full_screen_content_callback = _interstitial_callback
	InterstitialAdLoader.new().load(unit, AdRequest.new(), callback)

func _finish_interstitial() -> void:
	if _interstitial_ad != null:
		_interstitial_ad.destroy()
		_interstitial_ad = null
	_load_interstitial()

func _exit_tree() -> void:
	if _rewarded_ad != null:
		_rewarded_ad.destroy()
	if _interstitial_ad != null:
		_interstitial_ad.destroy()
