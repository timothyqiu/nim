extends HBoxContainer


signal mode_selected(mode)



func _on_5_pressed():
	emit_signal("mode_selected", Board.Mode.MODE_4)


func _on_10_pressed():
	emit_signal("mode_selected", Board.Mode.MODE_10)


func _on_Random_pressed():
	emit_signal("mode_selected", Board.Mode.MODE_RANDOM)
