extends RefCounted
## POP DROP Gravity: deterministic grid physics. Rendering is handled separately.
const SIZE := 8
const EMPTY := -1
const COLOR_COUNT := 3
const POP_THRESHOLD := 5
# Rock durability encoded as cells: 5=3 hits, 4=2 hits, 3=1 hit.
const ROCK_MIN := 3
const ROCK_MAX := 5

static func is_rock(cell: int) -> bool:
	return cell >= ROCK_MIN and cell <= ROCK_MAX

static func is_marble(cell: int) -> bool:
	return cell >= 0 and cell < COLOR_COUNT

static func wave_interval(waves_completed: int) -> float:
	# Fair mid-point between the old overwhelming 8s waves and the dull 18s mode.
	if waves_completed < 4:
		return 16.0
	if waves_completed < 9:
		return 14.0
	return 12.0

static func wave_marble_count(wave_number: int) -> int:
	if wave_number < 5:
		return 4
	if wave_number < 10:
		return 5
	return 6

static func wave_is_surge(wave_number: int) -> bool:
	# Every fifth wave is a clearly signalled, slightly heavier challenge.
	return wave_number > 0 and wave_number % 5 == 0

static func wave_total_marbles(wave_number: int) -> int:
	return mini(SIZE,wave_marble_count(wave_number) + (2 if wave_is_surge(wave_number) else 0))

static func rock_count(board: Array) -> int:
	var count: int = 0
	for row in board:
		for cell in row:
			if is_rock(int(cell)):
				count += 1
	return count

static func spawn_rock(board: Array, rng: RandomNumberGenerator) -> Dictionary:
	var result: Array = copy_board(board)
	var spots: Array = []
	for y in range(3,7):
		for x in range(SIZE):
			if int(result[y][x]) == EMPTY:
				spots.append(Vector2i(x,y))
	if spots.is_empty():
		return {"board":result,"spawned":false}
	var where: Vector2i = spots[rng.randi_range(0,spots.size()-1)]
	result[where.y][where.x] = ROCK_MAX
	return {"board":result,"spawned":true,"cell":where}

static func drop_wave(board: Array, rng: RandomNumberGenerator, marble_count: int) -> Dictionary:
	# Extra beads fall into DIFFERENT free columns, exactly like player pieces.
	# Full columns are skipped, not punished. Never delete or push the top row.
	var result: Array = copy_board(board)
	var motions: Array = []
	var eligible: Array = []
	for x in range(SIZE):
		if result[0][x] == EMPTY:
			eligible.append(x)
	for i in range(eligible.size()-1,0,-1):
		var pick: int = rng.randi_range(0,i)
		var temp: int = int(eligible[i])
		eligible[i] = eligible[pick]
		eligible[pick] = temp
	var added: int = 0
	for x in eligible:
		if added >= marble_count:
			break
		var bead: Array = [[0,0,rng.randi_range(0,COLOR_COUNT-1)]]
		var landing: Dictionary = drop(result,bead,int(x))
		if not bool(landing.get("valid",false)):
			continue
		result = landing["board"]
		motions.append_array(landing["motions"])
		added += 1
	return {"board":result,"motions":motions,"added":added}

static func damage_rocks(board: Array, popped: Array) -> Dictionary:
	# One adjacent POP stage = one hit, even if many balls touch the rock.
	var result: Array = copy_board(board)
	var affected: Dictionary = {}
	for position in popped:
		for direction in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
			var xy: Vector2i = position + direction
			if xy.x >= 0 and xy.x < SIZE and xy.y >= 0 and xy.y < SIZE:
				if is_rock(int(result[xy.y][xy.x])):
					affected[xy.y*SIZE+xy.x] = xy
	var cracked: Array = []
	var destroyed: Array = []
	for point in affected.values():
		var health: int = int(result[point.y][point.x])
		result[point.y][point.x] = EMPTY if health == ROCK_MIN else health-1
		cracked.append(point)
		if health == ROCK_MIN:
			destroyed.append(point)
	return {"board":result,"cracked":cracked,"destroyed":destroyed}



static func explode(board: Array, center: Vector2i) -> Dictionary:
	# Bomb destroys marbles in a 3x3 square and cracks each rock once.
	# It does not award score/XP/coins for the directly removed marbles.
	if center.x < 0 or center.y < 0 or center.x >= SIZE or center.y >= SIZE:
		return {"valid":false,"board":copy_board(board),"removed":0,"rocks_hit":0}
	var result: Array = copy_board(board)
	var removed: int = 0
	var stones: int = 0
	var cleared_cells: Array = []
	for y in range(maxi(0,center.y-1),mini(SIZE,center.y+2)):
		for x in range(maxi(0,center.x-1),mini(SIZE,center.x+2)):
			var value: int = int(result[y][x])
			if is_marble(value):
				result[y][x] = EMPTY
				removed += 1
				cleared_cells.append(Vector2i(x,y))
			elif is_rock(value):
				result[y][x] = EMPTY if value == ROCK_MIN else value-1
				stones += 1
	if removed == 0 and stones == 0:
		return {"valid":false,"board":copy_board(board),"removed":0,"rocks_hit":0}
	return {
		"valid":true,"board":result,"removed":removed,
		"rocks_hit":stones,"cells":cleared_cells
	}

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

static func clear_marbles(board: Array) -> Array:
	# Emergency clear may reset the balls, never a rock that needs 3 POP hits.
	var result: Array = copy_board(board)
	for y in range(SIZE):
		for x in range(SIZE):
			if is_marble(int(result[y][x])):
				result[y][x] = EMPTY
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
			if not is_marble(color) or visited.has(y * SIZE + x):
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

static func flow_multiplier_percent(streak: int) -> int:
	# Reward successive player-created POP actions. Automatic waves and bombs
	# do not increase the streak; never reduce rewards for the first POP.
	match clampi(streak,0,4):
		2: return 125
		3: return 150
		4: return 200
	return 100

static func score_groups(groups: Array, cascade_level: int = 1) -> int:
	var total: int = 0
	for group in groups:
		total += group_points(int(group["count"]))
	return total * maxi(1,cascade_level)

static func resolve_preview(board: Array, fluid: bool = false, clockwise: bool = true) -> Dictionary:
	# Pure equivalent of game._resolve_cascades(), for tests and previews.
	# Drop results can be resolved directly; rotations settle first.
	var after: Array = copy_board(board)
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
		var damaged: Dictionary = damage_rocks(after,hits)
		after = settle(erase_matches(damaged.board,hits)).board
		if fluid:
			after = spill_after_rotation(after,clockwise).board
	return {"score":total,"removed":popped,"chains":cascades,"board":after}

static func rotate_preview(board: Array, clockwise: bool) -> Dictionary:
	var turned: Array = settle(rotate(board,clockwise).board).board
	return resolve_preview(spill_after_rotation(turned,clockwise).board,true,clockwise)

static func drop_preview(board: Array, piece: Array, left_col: int) -> Dictionary:
	var result: Dictionary = drop(board,piece,left_col)
	if not result.get("valid",false):
		return {"valid":false}
	var resolved: Dictionary = resolve_preview(result.board)
	resolved["valid"] = true
	return resolved

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
			var color: int = int(board[y][x])
			if color == EMPTY:
				continue
			if is_rock(color):
				# An anchored stone separates independent falling segments.
				result[y][x] = color
				target_y = y-1
				continue
			result[target_y][x] = color
			if y != target_y:
				motions.append({"from":Vector2(x,y),"to":Vector2(x,target_y),"color":color})
			target_y -= 1
	return {"board":result,"motions":motions}

## A deliberately discrete, deterministic marble spill, applied ONLY after rotation.
## Each ball always loses height; no oscillation, random outcomes or teleporting.
## A roll requires a free side entrance AND a free diagonally lower destination.
## Tracks complete individual paths for a single smooth animation.
static func spill_after_rotation(board: Array, clockwise: bool) -> Dictionary:
	var result: Array = copy_board(board)
	var identities: Array = empty_board()
	var paths: Array = []
	var colors: Array = []
	for y in range(SIZE):
		for x in range(SIZE):
			if not is_marble(int(result[y][x])):
				continue
			identities[y][x] = paths.size()
			paths.append([Vector2(x,y)])
			colors.append(int(result[y][x]))
	var sideways_steps: int = 0
	for pass_index in range(SIZE*SIZE):
		var changed: bool = false
		# Traversing bottom-up avoids a moving bead being processed twice.
		# Scan direction alternates to make two equally good pockets fair.
		for y in range(SIZE-2,-1,-1):
			for order in range(SIZE):
				var x: int = order if (clockwise == (pass_index%2==0)) else SIZE-1-order
				if not is_marble(int(result[y][x])):
					continue
				var destination: Vector2i = Vector2i(-1,-1)
				if result[y+1][x] == EMPTY:
					destination = Vector2i(x,y+1)
				else:
					var direction: int = 1 if clockwise == (pass_index%2==0) else -1
					for attempt in range(2):
						var nx: int = x+direction
						if nx >= 0 and nx < SIZE:
							if result[y][nx] == EMPTY and result[y+1][nx] == EMPTY:
								destination = Vector2i(nx,y+1)
								sideways_steps += 1
								break
						direction = -direction
				if destination.x < 0:
					continue
				var particle_id: int = identities[y][x]
				result[destination.y][destination.x] = result[y][x]
				result[y][x] = EMPTY
				identities[destination.y][destination.x] = particle_id
				identities[y][x] = EMPTY
				paths[particle_id].append(Vector2(destination))
				changed = true
		if not changed:
			break
	var motions: Array = []
	for particle_id in range(paths.size()):
		var route: Array = paths[particle_id]
		if route.size() > 1:
			motions.append({"from":route[0],"to":route[route.size()-1],
				"color":colors[particle_id],"path":route})
	return {"board":result,"motions":motions,"rolls":sideways_steps}

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
		# Drop from above; cannot fall through an anchored rock.
		var landing: int = SIZE-1
		for y in range(SIZE):
			if result[y][x] != EMPTY:
				landing = y-1
				break
		if landing < 0:
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
	# A satisfying majority of shapes are 3–4 beads. Don't gift singles on
	# every crowded board; fallback in next_piece() still prevents unfair traps.
	if density > 0.72:
		if roll < 0.12:
			return 1
		if roll < 0.40:
			return 2
		if roll < 0.76:
			return 3
		return 4
	if density > 0.55:
		if roll < 0.06:
			return 1
		if roll < 0.30:
			return 2
		if roll < 0.68:
			return 3
		return 4
	if roll < 0.02:
		return 1
	if roll < 0.22:
		return 2
	if roll < 0.60:
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
	# No piece has five beads, so it cannot clear itself on an empty board.
	# Still validate its actual settled footprint: separate beads fall into
	# their columns instead of remaining a rigid tetromino.
	for attempt in range(12):
		var piece: Array = []
		for p in shape:
			var color: int = primary if rng.randf() < 0.49 else rng.randi_range(0,COLOR_COUNT-1)
			piece.append([p.x,p.y,color])
		var landed: Dictionary = drop(empty_board(),piece,0)
		if landed.get("valid",false) and find_matches(landed.board).is_empty():
			return piece
	# Defensive colour fallback (normal 1–4 bead pieces need no fallback).
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
			# Offer viable choices without automatically solving the next POP.
			# The old score gave near-guaranteed matches, making play passive.
			var rating: float = float(mini(playable,6))*0.16 + float(mini(useful,7))*0.23 + rng.randf_range(-3.0,3.0)
			if avoid_shapes.has(piece_shape_id(candidate)):
				rating -= 4.0
			if rating > highest:
				highest = rating
				best = candidate
		if not best.is_empty():
			return best
	# Fully blocked: the no-moves game-over check handles the loss.
	return [[0,0,rng.randi_range(0,COLOR_COUNT-1)]]

static func can_recover_by_rotating(board: Array, pieces: Array) -> bool:
	# Rotations are free; calculate whether ANY of the four orientations
	# can admit one of the offered pieces, including resulting POPs.
	for clockwise in [false,true]:
		var virtual: Array = copy_board(board)
		for quarter in range(4):
			virtual = rotate(virtual,clockwise).board
			virtual = settle(virtual).board
			virtual = spill_after_rotation(virtual,clockwise).board
			virtual = resolve_preview(virtual,true,clockwise).board
			for piece in pieces:
				if any_drop(virtual,piece):
					return true
	return false

static func rescue_for_continue(board: Array) -> Array:
	# A paid/ad rescue must yield at least one viable column, even when
	# the roof consists entirely of indestructible-to-POP rocks.
	var result: Array = rescue(board)
	var openings: int = 0
	for x in range(SIZE):
		if int(result[0][x]) == EMPTY:
			openings += 1
	if openings < 2:
		for x in [3,4,2,5,1,6,0,7]:
			if int(result[0][x]) != EMPTY:
				result[0][x] = EMPTY
				openings += 1
			if openings >= 2:
				break
	return result

static func rescue(board: Array) -> Array:
	var result: Array = copy_board(board)
	# Clear marbles from the two highest marble-bearing rows.
	# Rocks survive rescue (including after a rotation or a wave overflow).
	var cleared_rows: int = 0
	for y in range(SIZE):
		var has_marbles: bool = false
		for x in range(SIZE):
			if is_marble(int(result[y][x])):
				has_marbles = true
				result[y][x] = EMPTY
		if has_marbles:
			cleared_rows += 1
			if cleared_rows >= 2:
				break
	return settle(result).board
