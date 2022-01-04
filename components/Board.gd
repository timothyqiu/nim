tool
class_name Board
extends Control

signal game_start
signal game_over(winner)
signal can_end_turn(value)
signal turn_ended
signal turn_started(turn)

enum Turn { PLAYER_A, PLAYER_B }
enum Mode { MODE_4, MODE_10, MODE_RANDOM }

export var piece_scene: PackedScene
export var grid_size := Vector2(51, 51) setget set_grid_size
export var board_size := Vector2(10, 10) setget set_board_size
export var is_player_a_ai := false
export var is_player_b_ai := false

var board: Array
var mode: int = Mode.MODE_10
var turn: int setget set_turn
var row_determined: bool
var rng := RandomNumberGenerator.new()

onready var tween := $Tween as Tween


func _ready():
	rng.randomize()


func _draw():
	# draw checker board
	var color := get_color("grid", "Game")
	for y in board_size.y:
		for x in board_size.x:
			if x % 2 != y % 2:
				continue
			draw_rect(Rect2(grid_size * Vector2(x, y), grid_size), color)


func set_grid_size(value: Vector2) -> void:
	grid_size = value
	_update_board()


func set_board_size(value: Vector2) -> void:
	board_size = value
	_update_board()


func _update_board() -> void:
	rect_min_size = board_size * grid_size
	rect_size = rect_min_size
	update()


func _is_game_over() -> bool:
	for row in board:
		if not row.empty():
			return false
	return true


func _ai_move():
	var sum := 0
	for row in board:
		sum ^= row.size()
	
	var available_moves := []
	for i in board.size():
		var row := board[i] as Array
		var xor := row.size() ^ sum
		if xor < row.size():
			available_moves.append([i, xor])
	
	if available_moves.empty():
		push_warning("No good moves")
		for i in board.size():
			var row := board[i] as Array
			if not row.empty():
				available_moves.append([i, rng.randi() % row.size()])
	
	var target_row: int
	var target_size: int
	
	if available_moves.empty():
		push_warning("Unexpected: no available moves")
		return
	else:
		var move = available_moves[rng.randi() % available_moves.size()]
		target_row = move[0]
		target_size = move[1]
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	var row := board[target_row] as Array
	var take := row.slice(0, row.size() - target_size - 1)
	var delay := max(0.1, 1.0 / take.size())
	for piece in take:
		take_piece(piece, target_row)
		
		if piece == take.back():
			delay = 0.5
		yield(get_tree().create_timer(delay), "timeout")
	
	end_turn()


func start_game() -> void:
	for row in board:
		for piece in row:
			piece.queue_free()
	
	var size := PoolIntArray([])
	var cols := 0
	match mode:
		Mode.MODE_4:
			size.resize(4)
			for i in size.size():
				size[i] = 1 + i * 2
			cols = size.size() * 2 - 1
		Mode.MODE_10:
			size.resize(10)
			for i in size.size():
				size[i] = 1 + i
			cols = size.size()
		Mode.MODE_RANDOM:
			size.resize(3 + randi() % 8)
			for i in size.size():
				size[i] = 1 + randi() % (1 + i)
				if size[i] > cols:
					cols = size[i]
	
	self.board_size = Vector2(cols, size.size())
	board.resize(size.size())
	for row in size.size():
		board[row] = []
		
		for col in size[row]:
			var piece := piece_scene.instance() as Piece
			piece.mouse_filter = MOUSE_FILTER_IGNORE
			piece.rect_position = Vector2(col, row) * grid_size
			var err := piece.connect("pressed", self, "_on_Piece_pressed", [piece, row])
			assert(err == OK)
			
			board[row].append(piece)
			animate_putting(piece)
	
	yield(tween, "tween_all_completed")
	
	if OS.has_feature("debug"):
		print("[Game Start] Seed: ", rng.seed)
	emit_signal("game_start")
	
	set_turn(Turn.PLAYER_A if rng.randi() % 2 == 0 else Turn.PLAYER_B)


func is_ai_turn() -> bool:
	match turn:
		Turn.PLAYER_A:
			return is_player_a_ai
		Turn.PLAYER_B:
			return is_player_b_ai
	assert(false)
	return false


func set_turn(value: int) -> void:
	turn = value
	
	var is_ai := is_ai_turn()
	
	for row in board:
		for piece in row:
			piece.mouse_filter = MOUSE_FILTER_IGNORE if is_ai else MOUSE_FILTER_STOP
			piece.tween_disabled(false)
	
	row_determined = false
	
	Audio.play_sfx("EndTurn")
	if OS.has_feature("debug"):
		print("Turn Started: ", turn)
	emit_signal("turn_started", turn)
	
	if is_ai:
		call_deferred("_ai_move")


func end_turn() -> void:
	emit_signal("turn_ended")
	if _is_game_over():
		emit_signal("game_over", turn)
	else:
		set_turn(Turn.PLAYER_B if turn == Turn.PLAYER_A else Turn.PLAYER_A)


func take_piece(piece: Piece, row: int) -> void:
	if OS.has_feature("debug"):
		print("[%s] Take from row %d: %d left" % [turn, row, board[row].size() - 1])
	
	board[row].erase(piece)
	
	Audio.play_sfx("TakePiece")
	animate_taking(piece)


func _make_dummy_piece(piece: Piece) -> Sprite:
	var dummy := Sprite.new()
	add_child(dummy)
	dummy.modulate = piece.modulate
	dummy.texture = preload("res://assets/pressed.svg")
	dummy.position = piece.rect_position + piece.rect_size / 2
	return dummy
	
	
func animate_taking(piece: Piece) -> void:
	var dummy := _make_dummy_piece(piece)
	
	var fade_color := piece.modulate
	fade_color.a = 0
	
	var ok := true
	ok = tween.interpolate_property(dummy, "position", null, dummy.position + Vector2(10, -20), 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	ok = tween.interpolate_property(dummy, "rotation_degrees", 0, 10, 0.4, Tween.TRANS_SINE, Tween.EASE_OUT)
	ok = tween.interpolate_property(dummy, "modulate", null, fade_color, 0.3, Tween.TRANS_SINE, Tween.EASE_IN, 0.1)
	ok = tween.interpolate_deferred_callback(dummy, 0.5, "queue_free")
	ok = tween.start()
	assert(ok)
	
	piece.queue_free()


func animate_putting(piece: Piece) -> void:
	var dummy := _make_dummy_piece(piece)
	
	dummy.modulate.a = 0
	
	var ok := true
	ok = tween.interpolate_property(dummy, "position", dummy.position + Vector2(0, -20), dummy.position, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	ok = tween.interpolate_property(dummy, "rotation_degrees", -10, 0, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	ok = tween.interpolate_property(dummy, "modulate", null, piece.modulate, 0.3, Tween.TRANS_SINE, Tween.EASE_IN, 0.1)
	ok = tween.interpolate_deferred_callback(self, 0.5, "add_child", piece)
	ok = tween.interpolate_deferred_callback(dummy, 0.5, "queue_free")
	ok = tween.start()
	assert(ok)


func _on_Piece_pressed(piece: Piece, row: int) -> void:
	take_piece(piece, row)
	
	if not row_determined:
		for i in board.size():
			if i == row:
				continue
			for piece in board[i]:
				piece.mouse_filter = MOUSE_FILTER_IGNORE
				piece.tween_disabled(true)
	
	if board[row].empty():
		emit_signal("can_end_turn", false)
		yield(get_tree().create_timer(0.5), "timeout")
		end_turn()
	elif not row_determined:
		emit_signal("can_end_turn", true)
		row_determined = true

