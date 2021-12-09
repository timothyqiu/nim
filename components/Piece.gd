class_name Piece
extends TextureButton

onready var tween := $Tween as Tween
onready var tint := modulate


func tween_disabled(value):
	disabled = value
	
	var target_color = tint
	if disabled:
		target_color.v *= 1.2
		target_color.s *= 0.5
	
	var ok := tween.interpolate_property(
		self, "modulate", null, target_color,
		0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	assert(ok)
	ok = tween.start()
	assert(ok)
