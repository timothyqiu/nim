class_name LayeredContainer
extends MarginContainer

enum MutalTransition { OVERLAY, CROSSFADE }

export(MutalTransition) var mutal_transition = MutalTransition.OVERLAY
export var duration := 0.3

onready var tween := $Tween as Tween

var mutal_group := [] setget set_mutal_group
var mutal_group_max_index := 0
var children_visible := {}


func _ready():
	for child in get_children():
		if child is Control:
			child.visible = false
			child.modulate = Color.transparent
			children_visible[child] = false


func set_mutal_group(value: Array) -> void:
	mutal_group = value
	
	for node in mutal_group:
		if node.get_index() > mutal_group_max_index:
			mutal_group_max_index = node.get_index()


func toggle_child_visible(child: Control) -> void:
	set_child_visible(child, not children_visible[child])


func set_child_visible(child: Control, value: bool) -> void:
	if children_visible[child] == value:
		return
	
	children_visible[child] = value
	
	var ok := true
	
	if value and child in mutal_group:
		for node in mutal_group:
			if node == child:
				continue
			if not children_visible[node]:
				continue
			children_visible[node] = false
			_add_set_visible(node, false, duration if mutal_transition == MutalTransition.OVERLAY else 0.0)
		
		move_child(child, mutal_group_max_index)
	
	_add_set_visible(child, value)
	
	ok = tween.start()
	assert(ok)


func _add_set_visible(child: Control, value: bool, delay := 0.0) -> void:
	var ok := true
	
	ok = tween.remove(child)
	ok = tween.interpolate_property(
		child, "modulate", null, Color.white if value else Color.transparent,
		duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT, delay
	)
	if value:
		child.visible = true
	else:
		ok = tween.interpolate_callback(child, duration + delay, "hide")
	assert(ok)

