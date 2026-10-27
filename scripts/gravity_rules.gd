extends RefCounted
## POP DROP Gravity: deterministic grid physics. Rendering is handled separately.
const SIZE := 8
const EMPTY := -1
const COLOR_COUNT := 3

static func empty_board() -> Array:
	var result: Array = []
	for y in range(SIZE):
		var row: Array = []
		for x in range(SIZE):
			row.append(EMPTY)
		result.append(row)
	return result

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

static func find_matches(board: Array) -> Array:
	var visited: Dictionary = {}
	var hits: Array = []
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
			if group.size() >= 3:
				hits.append_array(group)
	return hits

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
		motions.append({"from":Vector2(x,-2.0-float(bead[1])),"to":Vector2(x,landing),"color":color})
	return {"valid":true,"board":result,"motions":motions}

static func any_drop(board: Array, piece: Array) -> bool:
	for x in range(SIZE):
		if drop(board,piece,x).get("valid",false):
			return true
	return false

static func make_piece(rng: RandomNumberGenerator, board: Array) -> Array:
	var density: float = float(filled(board)) / float(SIZE*SIZE)
	var roll: float = rng.randf()
	var shape: Array
	if density > 0.78 or roll < 0.10:
		shape = [Vector2i(0,0)]
	elif roll < 0.85:
		if rng.randf() < 0.50:
			shape = [Vector2i(0,0),Vector2i(0,1)]
		else:
			shape = [Vector2i(0,0),Vector2i(1,0)]
	else:
		var triple: int = rng.randi_range(0,2)
		if triple == 0:
			shape = [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1)]
		elif triple == 1:
			shape = [Vector2i(0,0),Vector2i(0,1),Vector2i(0,2)]
		else:
			shape = [Vector2i(0,0),Vector2i(1,0),Vector2i(2,0)]
	var primary: int = rng.randi_range(0,COLOR_COUNT-1)
	var piece: Array = []
	for p in shape:
		var color: int = primary if rng.randf() < 0.55 else rng.randi_range(0,COLOR_COUNT-1)
		piece.append([p.x,p.y,color])
	# No pre-made triple that explodes without consulting the existing board.
	if piece.size() >= 3:
		var all_same: bool = true
		for bead in piece:
			if int(bead[2]) != int(piece[0][2]):
				all_same = false
		if all_same:
			piece[-1][2] = (int(piece[-1][2])+1) % COLOR_COUNT
	return piece

static func next_piece(rng: RandomNumberGenerator, board: Array) -> Array:
	var best: Array = []
	var highest: float = -999999.0
	# Friendly candidate search: most rounds should offer a reasonable POP.
	for attempt in range(18):
		var candidate: Array = make_piece(rng,board)
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
		var rating: float = float(playable)*0.6 + float(mini(useful,7))*1.4 + rng.randf_range(-2.0,2.0)
		if rating > highest:
			highest = rating
			best = candidate
	if best.is_empty():
		# When the board is jammed, life/rescue logic will handle the loss.
		return [[0,0,rng.randi_range(0,COLOR_COUNT-1)]]
	return best

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
