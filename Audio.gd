extends Node


func play_sfx(name: String) -> void:
	if name.empty():
		return
	var node := $SFX.get_node(name) as AudioStreamPlayer
	node.play()

