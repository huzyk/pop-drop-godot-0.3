extends RefCounted
## Pure, deterministic gameplay: no graphics, no ads, no UI.
const SIZE := 8
const EMPTY := -1
const BASE_COLORS := 3
const SHAPES := [
	[Vector2i(0,0)],
	[Vector2i(0,0),Vector2i(1,0)],
	[Vector2i(0,0),Vector2i(0,1)],
	[Vector2i(0,0),Vector2i(1,0),Vector2i(2,0)],
	[Vector2i(0,0),Vector2i(0,1),Vector2i(0,2)],
	[Vector2i(0,0),Vector2i(1,0),Vector2i(0,1)],
	[Vector2i(0,0),Vector2i(1,0),Vector2i(1,1)],
	[Vector2i(0,0),Vector2i(0,1),Vector2i(1,1)],
	[Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)],
	[Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(1,1)],
	[Vector2i(0,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]
]

static func empty_board() -> Array:
	var b: Array = []
	for _y in range(SIZE):
		var row: Array = []
		for _x in range(SIZE):
			row.append(EMPTY)
		b.append(row)
	return b

static func copy_board(board: Array) -> Array:
	var cp: Array = []
	for row in board:
		cp.append(row.duplicate())
	return cp

static func count_filled(board: Array) -> int:
	var total := 0
	for row in board:
		for c in row:
			if c != EMPTY:
				total += 1
	return total

static func can_place(board: Array, piece: Array, anchor: Vector2i) -> bool:
	for bead in piece:
		var x: int = anchor.x + bead[0]
		var y: int = anchor.y + bead[1]
		if x < 0 or x >= SIZE or y < 0 or y >= SIZE:
			return false
		if board[y][x] != EMPTY:
			return false
	return true

static func any_placement(board: Array, piece: Array) -> bool:
	for y in range(SIZE):
		for x in range(SIZE):
			if can_place(board, piece, Vector2i(x,y)):
				return true
	return false

static func settle(board: Array) -> void:
	for x in range(SIZE):
		var write_y := SIZE - 1
		for y in range(SIZE - 1, -1, -1):
			if board[y][x] != EMPTY:
				var c: int = board[y][x]
				board[y][x] = EMPTY
				board[write_y][x] = c
				write_y -= 1

static func find_matches(board: Array) -> Array:
	var visited := {}
	var to_clear := {}
	for y in range(SIZE):
		for x in range(SIZE):
			var color: int = board[y][x]
			var key := y * SIZE + x
			if color == EMPTY or visited.has(key):
				continue
			var queue: Array = [Vector2i(x,y)]
			var component: Array = []
			visited[key] = true
			var index := 0
			while index < queue.size():
				var p: Vector2i = queue[index]
				index += 1
				component.append(p)
				for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
					var q: Vector2i = p + d
					if q.x < 0 or q.y < 0 or q.x >= SIZE or q.y >= SIZE:
						continue
					var neighbor_key: int = q.y * SIZE + q.x
					if not visited.has(neighbor_key) and board[q.y][q.x] == color:
						visited[neighbor_key] = true
						queue.append(q)
			if component.size() >= 3:
				for p in component:
					to_clear[p.y * SIZE + p.x] = p
	return to_clear.values()

static func simulate(board: Array, piece: Array, anchor: Vector2i, star_mode: bool = false) -> Dictionary:
	if not can_place(board,piece,anchor):
		return {"valid":false}
	var next := copy_board(board)
	for bead in piece:
		next[anchor.y+bead[1]][anchor.x+bead[0]] = bead[2]
	var removed := 0
	var chains := 0
	if star_mode:
		var cleared := {}
		# The STAR drop is a universal, cross-shaped clear centered on the landing cell.
		for k in range(SIZE):
			cleared[anchor.y*SIZE+k] = Vector2i(k,anchor.y)
			cleared[k*SIZE+anchor.x] = Vector2i(anchor.x,k)
		for p in cleared.values():
			if next[p.y][p.x] != EMPTY:
				next[p.y][p.x] = EMPTY
				removed += 1
		settle(next)
		chains += 1
	for _i in range(SIZE*SIZE):
		var matching: Array = find_matches(next)
		if matching.is_empty():
			break
		chains += 1
		removed += matching.size()
		for p in matching:
			next[p.y][p.x] = EMPTY
		settle(next)
	return {"valid":true,"board":next,"removed":removed,"chains":chains}

static func make_piece(shape_id: int, colors: Array) -> Array:
	var result: Array = []
	for i in range(SHAPES[shape_id].size()):
		var pos: Vector2i = SHAPES[shape_id][i]
		result.append([pos.x,pos.y,colors[i]])
	return result

static func intrinsic_matches(piece: Array) -> Array:
	# A shape with three adjacent beads of one colour would pop on its own.
	# Such pre-solved pieces are not allowed in the tray.
	var standalone: Array = empty_board()
	for bead in piece:
		standalone[int(bead[1])][int(bead[0])] = int(bead[2])
	return find_matches(standalone)


static func make_candidate(rng: RandomNumberGenerator, board: Array, color_count: int = BASE_COLORS) -> Array:
	var density: float = float(count_filled(board)) / float(SIZE*SIZE)
	var roll: float = rng.randf()
	var shape_id: int
	if density > 0.66:
		shape_id = rng.randi_range(0,2) if roll < 0.85 else rng.randi_range(3,6)
	elif roll < 0.17:
		shape_id = 0
	elif roll < 0.58:
		shape_id = rng.randi_range(1,2)
	elif roll < 0.91:
		shape_id = rng.randi_range(3,8)
	else:
		shape_id = rng.randi_range(9,10)
	var dominant: int = rng.randi_range(0,color_count-1)
	# Often use a color already on the board, for meaningful combinations.
	if count_filled(board) > 0 and rng.randf() < 0.72:
		for _tries in range(12):
			var px := rng.randi_range(0,SIZE-1)
			var py := rng.randi_range(0,SIZE-1)
			if board[py][px] != EMPTY:
				dominant = board[py][px]
				break
	var colors: Array = []
	for _p in SHAPES[shape_id]:
		colors.append(dominant if rng.randf() < 0.82 else rng.randi_range(0,color_count-1))
	var piece: Array = make_piece(shape_id,colors)
	# Repair groups that would explode BEFORE touching any existing board balls.
	# Preserve same-colour pairs: they help the player plan very easy clears.
	for _repair in range(8):
		var internal: Array = intrinsic_matches(piece)
		if internal.is_empty():
			return piece
		var affected: Vector2i = internal[rng.randi_range(0,internal.size()-1)]
		for bead in piece:
			if int(bead[0]) == affected.x and int(bead[1]) == affected.y:
				var next_color: int = (int(bead[2]) + rng.randi_range(1,color_count-1)) % color_count
				bead[2] = next_color
				break
	# Guaranteed fallback even after unlucky re-rolls.
	for i in range(piece.size()):
		piece[i][2] = (dominant+i) % color_count
	return piece

static func evaluate_candidate(board: Array, piece: Array) -> Dictionary:
	# Evaluate every legal landing spot, and keep a concrete move for lookahead.
	var fit := 0
	var clears := 0
	var high := 0
	var best_chain := 0
	var best_anchor := Vector2i(-1,-1)
	var best_board: Array = []
	var best_move_value := -1000000.0
	for y in range(SIZE):
		for x in range(SIZE):
			var at := Vector2i(x,y)
			if not can_place(board,piece,at):
				continue
			fit += 1
			var r: Dictionary = simulate(board,piece,at)
			if int(r.removed) > 0:
				clears += 1
			high = maxi(high,int(r.removed))
			best_chain = maxi(best_chain,int(r.chains))
			# A clear is useful because it frees space. Prefer cascades, too.
			var value: float = float(r.removed)*3.0 + float(r.chains)*5.0 - float(count_filled(r.board))*0.08
			if value > best_move_value:
				best_move_value = value
				best_anchor = at
				best_board = r.board
	return {"fits":fit,"clears":clears,"best":high,"chains":best_chain,
		"anchor":best_anchor,"after":best_board}


static func generate_tray_plan(board: Array, rng: RandomNumberGenerator, color_count: int = 3) -> Dictionary:
	# This is a FRIENDLY generator, not a timer or a forced-loss script.
	# Each piece is evaluated on a plausible board AFTER playing the previous one.
	# The returned anchors form a reproducible witness for a legal 3-piece sequence,
	# except on a truly saturated board with no viable path.
	var chosen: Array = []
	var anchors: Array = []
	var virtual_board: Array = copy_board(board)
	for slot in range(3):
		var possibilities: Array = []
		var density: float = float(count_filled(virtual_board)) / float(SIZE*SIZE)
		for _attempt in range(18):
			var piece: Array = make_candidate(rng,virtual_board,color_count)
			# Keep the tray easy to understand: every offered piece should ALSO fit
			# the current real board, not only a hypothetical future board.
			if not any_placement(board,piece):
				continue
			var assessment: Dictionary = evaluate_candidate(virtual_board,piece)
			if assessment.fits == 0:
				continue
			# Don't knowingly close the very last gap before the final tray piece.
			if slot < 2 and count_filled(assessment.after) == SIZE*SIZE:
				continue
			var rating: float = minf(assessment.fits,24)*0.12
			rating += minf(assessment.clears,12)*1.6 + minf(assessment.best,9)*1.0
			rating += assessment.chains*2.5
			if density > 0.55:
				rating += 7.0 if piece.size() <= 2 else -4.0
			rating += rng.randf_range(-2.5,2.5)
			possibilities.append({"piece":piece,"anchor":assessment.anchor,
				"after":assessment.after,"score":rating})
		if possibilities.is_empty():
			# Try every colour as a 1-ball lifeline before admitting there is no plan.
			for c in range(color_count):
				var single: Array = make_piece(0,[c])
				if not any_placement(board,single):
					continue
				var evaluation: Dictionary = evaluate_candidate(virtual_board,single)
				if evaluation.fits == 0:
					continue
				if slot < 2 and count_filled(evaluation.after) == SIZE*SIZE:
					continue
				possibilities.append({"piece":single,"anchor":evaluation.anchor,
					"after":evaluation.after,"score":float(evaluation.best)*3.0})
		if possibilities.is_empty():
			break
		possibilities.sort_custom(func(a,b): return a.score > b.score)
		var shortlist: int = mini(possibilities.size(), 3 if slot < 2 else 5)
		var selected: Dictionary = possibilities[rng.randi_range(0,shortlist-1)]
		chosen.append(selected.piece)
		anchors.append(selected.anchor)
		virtual_board = copy_board(selected.after)
	return {"tray":chosen,"anchors":anchors}


static func generate_tray(board: Array, rng: RandomNumberGenerator, color_count: int = 3) -> Array:
	var result: Dictionary = generate_tray_plan(board,rng,color_count)
	var chosen: Array = result.tray
	# On a completely jammed board the life/rescue system takes over.
	# Still supply three slots, so the UI always has a consistent tray.
	while chosen.size() < 3:
		chosen.append(make_piece(0,[rng.randi_range(0,color_count-1)]))
	return chosen

static func rescue(board: Array) -> Array:
	var next := copy_board(board)
	var removed := 0
	for y in range(SIZE):
		var filled := 0
		for x in range(SIZE):
			if next[y][x] != EMPTY:
				filled += 1
		if filled > 0:
			for x in range(SIZE):
				next[y][x] = EMPTY
			removed += filled
			if removed >= 8:
				break
	settle(next)
	return next

static func resolve_after_booster(board: Array) -> Dictionary:
	var next := copy_board(board)
	settle(next)
	var removed := 0
	var chains := 0
	for _i in range(SIZE*SIZE):
		var matches := find_matches(next)
		if matches.is_empty():
			break
		chains += 1
		removed += matches.size()
		for p in matches:
			next[p.y][p.x] = EMPTY
		settle(next)
	return {"board":next,"removed":removed,"chains":chains}
