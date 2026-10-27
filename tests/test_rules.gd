extends SceneTree
const Rules = preload("res://scripts/rules.gd")

func _initialize() -> void:
 var checks := 0
 var board := Rules.empty_board()
 assert(board.size() == 8)
 board[7][1] = 0
 board[7][2] = 0
 var result: Dictionary = Rules.simulate(board,[[0,0,0]],Vector2i(3,7))
 assert(result.valid and result.removed == 3 and result.chains == 1)
 checks += 1
 assert(not Rules.simulate(board,[[0,0,1]],Vector2i(2,7)).valid)
 checks += 1
 var rng := RandomNumberGenerator.new()
 rng.seed = 20261026
 for i in range(75):
  var tray: Array = Rules.generate_tray(board,rng)
  assert(tray.size() == 3)
  for piece in tray:
   assert(piece.size() >= 1 and piece.size() <= 4)
   assert(Rules.any_placement(board,piece))
   checks += 1
 print("POP DROP smoke test OK: ",checks," checks")
 quit()
