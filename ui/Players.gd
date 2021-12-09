class_name Players
extends Container

signal end_turn

enum PlayerType { HUMAN, CPU }
enum State { INACTIVE, LEFT_ACTIVE, RIGHT_ACTIVE }

const HUMAN_TEXTURE: Texture = preload("res://assets/human.svg")
const CPU_TEXTURE: Texture = preload("res://assets/cpu.svg")

export(PlayerType) var left_type: int = PlayerType.HUMAN setget set_left_type
export(PlayerType) var right_type: int = PlayerType.HUMAN setget set_right_type
export(State) var state: int = State.INACTIVE setget set_state
export var can_end_turn := true setget set_can_end_turn


func set_left_type(v: int) -> void:
	left_type = v
	$LeftAvatar.texture = HUMAN_TEXTURE if v == PlayerType.HUMAN else CPU_TEXTURE


func set_right_type(v: int) -> void:
	right_type = v
	$RightAvatar.texture = HUMAN_TEXTURE if v == PlayerType.HUMAN else CPU_TEXTURE


func set_state(v: int) -> void:
	state = v
	
	var active_tint := get_color("info_normal", "Game")
	var inactive_tint := get_color("info_disabled", "Game")
	
	var left_tint := active_tint if state == State.LEFT_ACTIVE else inactive_tint
	var right_tint := active_tint if state == State.RIGHT_ACTIVE else inactive_tint
	
	var left_avatar := $LeftAvatar as TextureRect
	var right_avatar := $RightAvatar as TextureRect
	
	if is_inside_tree():
		var tween := $Tween as Tween
		var ok := true
		
		ok = tween.interpolate_property(
			self, "modulate", null, Color.white,
			0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT
		)
		ok = tween.interpolate_property(
			left_avatar, "modulate", null, left_tint,
			0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT
		)
		ok = tween.interpolate_property(
			right_avatar, "modulate", null, right_tint,
			0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT
		)
		
		ok = tween.start()
		assert(ok)
	else:
		left_avatar.modulate = left_tint
		right_avatar.modulate = right_tint
	
	if state == State.INACTIVE and can_end_turn:
		set_can_end_turn(false)
		property_list_changed_notify()


func set_can_end_turn(v: bool) -> void:
	can_end_turn = v
	$EndTurn.animate_disabled(not can_end_turn)


func _on_EndTurn_pressed():
	emit_signal("end_turn")
