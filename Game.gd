extends Control

onready var header := $Content/Header as LayeredContainer
onready var players := $Content/Header/Players as Players
onready var title := $Content/Header/Title as Label
onready var main := $Content/Main as LayeredContainer
onready var board := $Content/Main/Board as Board
onready var opponent_select := $Content/Main/OpponentSelect
onready var mode_select := $Content/Main/ModeSelect
onready var rules := $Content/Main/Rules as Control
onready var credits := $Content/Main/Credits as Control
onready var winner_label := $Content/Main/Winner as Label
onready var mute_button := $Controls/Buttons/Mute as SimpleButton

var in_title_screen: bool = true


func _ready():
	_update_mute_button()
	
	header.mutal_group = [players, title]
	header.set_child_visible(title, true)
	
	main.mutal_group = [rules, credits]
	main.set_child_visible(board, true)
	
	yield(get_tree().create_timer(0.5), "timeout")
	main.set_child_visible(opponent_select, true)
	main.set_child_visible(mode_select, false)


func start_game():
	board.start_game()


func _update_mute_button():
	if AudioServer.is_bus_mute(0):
		mute_button.texture_normal = preload("res://assets/audio_off.svg")
	else:
		mute_button.texture_normal = preload("res://assets/audio_on.svg")


func _on_Board_turn_started(turn):
	match turn:
		Board.Turn.PLAYER_A:
			players.state = Players.State.LEFT_ACTIVE
		Board.Turn.PLAYER_B:
			players.state = Players.State.RIGHT_ACTIVE


func _on_Board_turn_ended():
	players.can_end_turn = false


func _on_Board_can_end_turn(value):
	players.can_end_turn = value


func _on_Board_game_over(winner):
	players.state = Players.State.INACTIVE
	yield(get_tree().create_timer(1), "timeout")
	players.state = Players.State.LEFT_ACTIVE if winner == Board.Turn.PLAYER_A else Players.State.RIGHT_ACTIVE
	main.set_child_visible(winner_label, true)
	Audio.play_sfx("Winner")


func _on_Players_end_turn():
	board.end_turn()
	main.set_child_visible(rules, false)
	main.set_child_visible(credits, false)


func _on_Credits_pressed():
	main.toggle_child_visible(credits)


func _on_Rules_pressed():
	main.toggle_child_visible(rules)


func _on_Restart_pressed():
	if in_title_screen:
		get_tree().quit()
	else:
		Globals.animate_reload_scene()
		in_title_screen = true


func _on_OpponentSelect_opponent_selected(type):
	in_title_screen = false
	main.set_child_visible(opponent_select, false)
	main.set_child_visible(mode_select, true)
	players.right_type = type
	players.state = Players.State.INACTIVE
	board.is_player_b_ai = type == Players.PlayerType.CPU
	


func _on_Mute_pressed():
	AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))
	_update_mute_button()


func _on_ModeSelect_mode_selected(mode):
	main.set_child_visible(mode_select, false)
	header.set_child_visible(players, true)
	board.mode = mode
	start_game()
