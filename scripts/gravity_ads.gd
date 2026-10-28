extends Node
## Reward safety contract. Fails closed until a real, consent-aware SDK
## adapter is attached. No mock rewards in release/gameplay builds.
signal reward_earned(transaction: int)
signal rewarded_unavailable
var provider: Node = null
var next_transaction: int = 0
var pending_transaction: int = -1

func attach_provider(adapter: Node) -> void:
	if provider != null:
		if provider.reward_earned.is_connected(_confirm_reward):
			provider.reward_earned.disconnect(_confirm_reward)
	provider = adapter
	if provider != null:
		provider.reward_earned.connect(_confirm_reward)

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
