extends Node2D

onready var Grid = $".";

var Block = preload("res://Block/Block.tscn");
var block_size = 24;
var offset = block_size;
var board_size = 3
var board = []
var flat_board = []
var active_player = 'x'
var is_winner = false
var win_blocks = []

func _ready():
	_create_board()

func _process(delta):
	_detect_mouse_input()

func _create_board():
	for row in range(board_size):
		board.append([])
		for column in range(board_size):
			_create_block(row, column)

func _create_block(row, column):
	var block = Block.instance();
	Grid.add_child(block)
	block.position = _grid_to_pixel(row, column)
	board[row].append(block)


func _detect_mouse_input():
	if Input.is_action_just_pressed("ui_touch"):
		var mouse_pos = get_global_mouse_position()
		var grid_pos = _pixel_to_grid(mouse_pos)

		if _is_in_grid(grid_pos):
			_handle_mouse_click(grid_pos)

func _handle_mouse_click(grid_pos):
	_set_block_value(grid_pos.x, grid_pos.y)
	_update_flat_board()
	
	# TODO: Detect Draw
	# TODO: Detect winner player
	# TODO: Detect is block not emoty
	# TODO: https://levelup.gitconnected.com/mastering-tic-tac-toe-with-minimax-algorithm-3394d65fa88f
	if !_check_win():
		var next_move = _find_best_move()
		next_move.state = 'o'
		_update_flat_board()
	else:
		print('Win')

	

func _update_flat_board():
	flat_board = []
	for column_index in range(board_size):
		flat_board.append([])
		for row_index in range(board_size):
			var block = board[column_index][row_index]
			flat_board[column_index].append(block.state);

func _check_win():
	var score = _evaluate(flat_board)
	
	if score == 10 || score == -10:
		return true
	else:
		return false

func _set_block_value(column, row):
	var block = board[column][row]
	block.state = active_player
	
func _change_player():
	if active_player == 'x':
		active_player = 'o'
	elif active_player == 'o':
		active_player = 'x'

func _is_in_grid(grid):
	var is_column_in_grid = grid.x >= 0 && grid.x < board_size
	var is_row_in_grid = grid.y >= 0 && grid.y < board_size
	return is_column_in_grid && is_row_in_grid

func _grid_to_pixel(column, row):
	var grid_column = 12 + offset * column
	var grid_row = 12 + offset * row
	return Vector2(grid_column, grid_row)
	
func _pixel_to_grid(pos):
	var column = round((pos.x  - 12) / offset)
	var row = round((pos.y - 12) / offset)
	return Vector2(column, row)

# AI
func _is_move_left() -> bool:
	for column_index in range(board_size):
		for row_index in range(board_size):
			var block = board[column_index][row_index]
			if block.state == '':
				return true
	return false

func _get_score(block):
	if block == 'x':
		return 10
	elif block == 'o':
		return -10
	else:
		return 0


func _evaluate(flat_board) -> int:
	# Checking for Columns for X or O victory
	
	for column_index in range(board_size):
		var block_1 = flat_board[column_index][0]
		var block_2 = flat_board[column_index][1]
		var block_3 = flat_board[column_index][2]
		
		if block_1 == block_2 && block_2 == block_3:
			return _get_score(block_1)

	# Checking for Rows for X or O victory
	for row_index in range(board_size):
		var block_1 = flat_board[0][row_index]
		var block_2 = flat_board[1][row_index]
		var block_3 = flat_board[2][row_index]
		
		if block_1 == block_2 && block_2 == block_3:
			return _get_score(block_1)

	# Checking for Diagonals for X or O victory
	var block_top_left = flat_board[0][0]
	var block_top_right = flat_board[0][2]
	var block_center = flat_board[1][1]
	var block_bottom_right = flat_board[2][2]
	var block_bottom_left = flat_board[2][0]

	if block_top_left == block_center && block_center == block_bottom_right:
		return _get_score(block_center)

	if block_top_right == block_center && block_center == block_bottom_left:
		return _get_score(block_center)
		
	return 0

func _find_best_move():
	var best = -1000
	var best_move
	
	for column_index in range(board_size):
		for row_index in range(board_size):
			var block = flat_board[column_index][row_index]
			
			if block == '':
				flat_board[column_index][row_index] = 'o'
				var move_score = minimax(flat_board)
				flat_board[column_index][row_index] = ''
				
				if move_score > best: 
					best = move_score;
					best_move = board[column_index][row_index]
					
	return best_move

func minimax(temp_board) -> int:
	var score: int = _evaluate(temp_board)
	var scores: Array = []
	var best: int = 1000

	if score == 10 || score == -10:
		return score

	if !(_is_move_left()):
		return 0

	for column_index in range(board_size):
		for row_index in range(board_size):
			var block = temp_board[column_index][row_index]

			if block == '':
				temp_board[column_index][row_index] = 'o'
				best = min(best, minimax(temp_board))
				temp_board[column_index][row_index] = ''
				
	return 0
