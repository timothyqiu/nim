class_name SimpleButton
extends TextureButton

enum State { NORMAL, HOVERED, PRESSED }

export var sound := "Button"
export var blink := false
export var use_alt_pressed_color := false

onready var normal_color = get_color("info", "Game")
onready var hover_color = get_color("interactable", "Game")
onready var pressed_color = get_color("grid" if use_alt_pressed_color else "background", "Game")

var state: int = State.NORMAL setget set_state



func _ready():
	set_state(State.NORMAL)


func _process(_delta: float):
	if blink and state == State.NORMAL and not disabled and not $Tween.is_active():
		var tween := $BlinkTween as Tween
		if not tween.is_active():
			var ok := true
			ok = tween.interpolate_property(self, "modulate:a", 1.0, 0.3, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			ok = tween.interpolate_property(self, "modulate:a", 0.3, 1.0, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1.0)
			ok = tween.start()
			assert(ok)


func set_state(v: int) -> void:
	state = v
	
	if not disabled:
		match state:
			State.NORMAL:
				_tween_modulate(normal_color)
			State.HOVERED:
				_tween_modulate(hover_color)
			State.PRESSED:
				_tween_modulate(pressed_color)


func _tween_modulate(target: Color) -> void:
	$BlinkTween.remove_all()
	if is_inside_tree():
		$Tween.interpolate_property(self, "modulate", null, target, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.start()
	else:
		modulate = target


func animate_disabled(value: bool) -> void:
	disabled = value
	
	if disabled:
		_tween_modulate(Color.transparent)
	else:
		set_state(state)


func _on_SimpleButton_button_down():
	set_state(State.PRESSED)


func _on_SimpleButton_button_up():
	set_state(State.HOVERED)


func _on_SimpleButton_mouse_entered():
	set_state(State.HOVERED)


func _on_SimpleButton_mouse_exited():
	set_state(State.NORMAL)


func _on_SimpleButton_pressed():
	Audio.play_sfx(sound)
