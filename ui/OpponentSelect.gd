extends VBoxContainer

signal opponent_selected(type)


func _on_CPU_pressed():
	emit_signal("opponent_selected", Players.PlayerType.CPU)


func _on_Human_pressed():
	emit_signal("opponent_selected", Players.PlayerType.HUMAN)
