extends RefCounted
## POP DROP Gravity: deterministic grid physics. Rendering is handled separately.
const SIZE := 8
const EMPTY := -1
const COLOR_COUNT := 3
const POP_THRESHOLD := 5

const SHAPES_BY_SIZE := [
	# Twelve recognisable silhouettes. The Z and S are intentionally separate.
	# 1 single
	[[Vector2i(0,0)]],
	# 2 pairs: horizontal, vertical
	[[Vector2i(0,0),Vector2i(1,0)],
	 [Vector2i(0,0),Vector2i(0,1)]],
	# 3 triples: horizontal, vertical, corner
	[[Vector2i(0,0),Vector2i(1,0),Vector2i(2,0)],
	 [Vector2i(0,0),Vector2i(0,1),Vector2i(0,2)],
	 [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1)]],
	# 4 balls: bar, square, L, T, S, Z
	[[Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(3,0)],
	 [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)],
	 [Vector2i(0,0),Vector2i(0,1),Vector2i(0,2),Vector2i(1,2)],
	 [Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(1,1)],
	 [Vector2i(1,0),Vector2i(2,0),Vector2i(0,1),Vector2i(1,1)],
	 [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(2,1)]]
]

static func piece_shape_id(piece: Array) -> String:
	# Colours do not affect shape identity; this keeps consecutive previews varied.
	var result: String = ""
	for bead in piece:
		result += "%d:%d;" % [int(bead[0]),int(bead[1])]
	return result

static func empty_board() -> Array:
	var result: Array = []
	for y in range(SIZE):
		var row: Array = []
		for x in range(SIZE):
			row.append(EMPTY)
		result.append(row)
	return result

static func ceiling_reached(board: Array) -> bool:
	# One shared, visible game-over boundary: the top row of the grid.
	for color in board[0]:
		if color != EMPTY:
			return true
	return false

static func tallest_column(board: Array) -> int:
	var tallest: int = 0
	for x in range(SIZE):
		for y in range(SIZE):
			if board[y][x] != EMPTY:
				tallest = maxi(tallest,SIZE-y)
				break
	return tallest

static func copy_board(board: Array) -> Array:
	var result: Array = []
	for row in board:
		result.append(row.duplicate())
	return result

static func filled(board: Array) -> int:
	var total: int = 0
	for row in board:
		for bead in row:
			if bead != EMPTY:
				total += 1
	return total

static func find_groups(board: Array, minimum: int = POP_THRESHOLD) -> Array:
	# Return separate connected colour groups. A 6-ball group scores differently
	# from two independent 3-ball groups, so flattening loses information.
	var visited: Dictionary = {}
	var groups: Array = []
	for y in range(SIZE):
		for x in range(SIZE):
			var color: int = board[y][x]
			if color == EMPTY or visited.has(y * SIZE + x):
				continue
			var group: Array = []
			var queue: Array = [Vector2i(x,y)]
			visited[y * SIZE + x] = true
			var index: int = 0
			while index < queue.size():
				var point: Vector2i = queue[index]
				index += 1
				group.append(point)
				for delta in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
					var neighbor: Vector2i = point + delta
					if neighbor.x < 0 or neighbor.x >= SIZE or neighbor.y < 0 or neighbor.y >= SIZE:
						continue
					var key: int = neighbor.y * SIZE + neighbor.x
					if not visited.has(key) and board[neighbor.y][neighbor.x] == color:
						visited[key] = true
						queue.append(neighbor)
			if group.size() >= minimum:
				groups.append({"cells":group,"color":color,"count":group.size()})
	return groups

static func find_matches(board: Array) -> Array:
	var hits: Array = []
	for group in find_groups(board):
		hits.append_array(group["cells"])
	return hits

static func group_points(count: int) -> int:
	# The deliberate risk/reward curve for holding a group before triggering it.
	if count < POP_THRESHOLD:
		return 0
	var rewards: Array = [320,560,900,1400]
	if count <= 8:
		return rewards[count-POP_THRESHOLD]
	var extra: int = count - 8
	return 1400 + extra*600 + extra*extra*90

static func score_groups(groups: Array, cascade_level: int = 1) -> int:
	var total: int = 0
	for group in groups:
		total += group_points(int(group["count"]))
	return total * maxi(1,cascade_level)

static func rotate_preview(board: Array, clockwise: bool) -> Dictionary:
	# Exact deterministic preview: same rotate -> settle -> pop loop as gameplay.
	# No points are paid until the real rotation is performed.
	var after: Array = settle(rotate(board,clockwise).board).board
	var total: int = 0
	var popped: int = 0
	var cascades: int = 0
	for stage in range(SIZE*SIZE):
		var groups: Array = find_groups(after)
		if groups.is_empty():
			break
		cascades += 1
		total += score_groups(groups,cascades)
		var hits: Array = []
		for group in groups:
			hits.append_array(group["cells"])
		popped += hits.size()
		after = settle(erase_matches(after,hits)).board
	return {"score":total,"removed":popped,"chains":cascades,"board":after}

static func erase_matches(board: Array, matches: Array) -> Array:
	var result: Array = copy_board(board)
	for point in matches:
		result[point.y][point.x] = EMPTY
	return result

static func rotate(board: Array, clockwise: bool) -> Dictionary:
	var result: Array = empty_board()
	var motions: Array = []
	for y in range(SIZE):
		for x in range(SIZE):
			var color: int = board[y][x]
			if color == EMPTY:
				continue
			var dst: Vector2i
			if clockwise:
				dst = Vector2i(SIZE - 1 - y,x)
			else:
				dst = Vector2i(y,SIZE - 1 - x)
			result[dst.y][dst.x] = color
			motions.append({"from":Vector2(x,y),"to":Vector2(dst),"color":color})
	return {"board":result,"motions":motions}

static func settle(board: Array) -> Dictionary:
	var result: Array = empty_board()
	var motions: Array = []
	for x in range(SIZE):
		var target_y: int = SIZE - 1
		for y in range(SIZE - 1,-1,-1):
			var color: int = board[y][x]
			if color == EMPTY:
				continue
			result[target_y][x] = color
			if y != target_y:
				motions.append({"from":Vector2(x,y),"to":Vector2(x,target_y),"color":color})
			target_y -= 1
	return {"board":result,"motions":motions}

static func drop(board: Array, piece: Array, left_col: int) -> Dictionary:
	var result: Array = copy_board(board)
	var cells: Array = piece.duplicate(true)
	# Bottommost part of each vertical shape falls first.
	cells.sort_custom(func(a,b): return int(a[1]) > int(b[1]))
	var motions: Array = []
	for bead in cells:
		var x: int = left_col + int(bead[0])
		if x < 0 or x >= SIZE:
			return {"valid":false}
		var landing: int = -1
		for y in range(SIZE - 1,-1,-1):
			if result[y][x] == EMPTY:
				landing = y
				break
		if landing == -1:
			return {"valid":false}
		var color: int = int(bead[2])
		result[landing][x] = color
		motions.append({"from":Vector2(x,-float(piece.size()+1)+float(bead[1])),"to":Vector2(x,landing),"color":color})
	return {"valid":true,"board":result,"motions":motions}

static func any_drop(board: Array, piece: Array) -> bool:
	for x in range(SIZE):
		if drop(board,piece,x).get("valid",false):
			return true
	return false

static func choose_piece_size(rng: RandomNumberGenerator, board: Array) -> int:
	var density: float = float(filled(board)) / float(SIZE*SIZE)
	var roll: float = rng.randf()
	# Four-ball silhouettes now show up often enough to learn to recognise them.
	# Once the board fills, small pieces remain available as lifelines.
	if density > 0.72:
		if roll < 0.24:
			return 1
		if roll < 0.79:
			return 2
		return 3
	if density > 0.55:
		if roll < 0.12:
			return 1
		if roll < 0.54:
			return 2
		if roll < 0.88:
			return 3
		return 4
	if roll < 0.06:
		return 1
	if roll < 0.40:
		return 2
	if roll < 0.71:
		return 3
	return 4

static func make_piece(rng: RandomNumberGenerator, board: Array, desired_size: int = 0) -> Array:
	var piece_size: int = desired_size if desired_size > 0 else choose_piece_size(rng,board)
	piece_size = clampi(piece_size,1,4)
	var shapes: Array = SHAPES_BY_SIZE[piece_size-1]
	var shape_index: int = rng.randi_range(0,shapes.size()-1)
	# Highlight S and Z more frequently than other 4-ball silhouettes.
	if piece_size == 4 and rng.randf() < 0.30:
		shape_index = rng.randi_range(4,5)
	var shape: Array = shapes[shape_index]
	var primary: int = rng.randi_range(0,COLOR_COUNT-1)
	# A piece must not create a 3-of-a-kind POP on an empty board.
	# Test the actual settled landing, not just the outline of the shape:
	# individual beads split apart when dropped.
	for attempt in range(12):
		var piece: Array = []
		for p in shape:
			var color: int = primary if rng.randf() < 0.58 else rng.randi_range(0,COLOR_COUNT-1)
			piece.append([p.x,p.y,color])
		var landed: Dictionary = drop(empty_board(),piece,0)
		if landed.get("valid",false) and find_matches(landed.board).is_empty():
			return piece
	# At most two beads share any one colour: no automatic POP is possible.
	var fallback: Array = []
	for i in range(shape.size()):
		var p: Vector2i = shape[i]
		fallback.append([p.x,p.y,(primary+i)%COLOR_COUNT])
	return fallback

static func next_piece(rng: RandomNumberGenerator, board: Array, avoid_shapes: Array = []) -> Array:
	# Select the size BEFORE ranking the candidates. Otherwise the lookahead
	# consistently prefers big pieces and overrides the intended distribution.
	var desired_size: int = choose_piece_size(rng,board)
	for target_size in range(desired_size,0,-1):
		var best: Array = []
		var highest: float = -999999.0
		for attempt in range(20):
			var candidate: Array = make_piece(rng,board,target_size)
			var playable: int = 0
			var useful: int = 0
			for col in range(SIZE):
				var trial: Dictionary = drop(board,candidate,col)
				if not trial.get("valid",false):
					continue
				playable += 1
				useful = maxi(useful,find_matches(trial.board).size())
			if playable == 0:
				continue
			# Reward useful opportunities but don't always select the widest
			# or shortest outline: meaningful variety matters to the player.
			var rating: float = float(mini(playable,6))*0.25 + float(mini(useful,7))*1.0 + rng.randf_range(-2.5,2.5)
			# A new silhouette is worth more than one more easy clear.
			if avoid_shapes.has(piece_shape_id(candidate)):
				rating -= 10.0
			if rating > highest:
				highest = rating
				best = candidate
		if not best.is_empty():
			return best
	# Fully blocked: the life/rescue system handles the loss.
	return [[0,0,rng.randi_range(0,COLOR_COUNT-1)]]

static func rescue(board: Array) -> Array:
	var result: Array = copy_board(board)
	# Clear the two highest occupied rows, then settle again.
	var rows: int = 0
	for y in range(SIZE):
		var occupied: bool = false
		for x in range(SIZE):
			if result[y][x] != EMPTY:
				occupied = true
		if occupied:
			for x in range(SIZE):
				result[y][x] = EMPTY
			rows += 1
			if rows >= 2:
				break
	return settle(result).board
