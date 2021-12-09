tool
extends SimpleButton

export var text := "URLButton" setget set_text
export var url: String


func set_text(v: String) -> void:
	text = v
	$Label.text = v
	rect_min_size = $Label.get_minimum_size()


func _on_URLButton_pressed():
	if url:
		var err := OS.shell_open(url)
		assert(err == OK)
