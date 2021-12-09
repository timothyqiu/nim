extends Node

var tween := Tween.new()


func _ready():
	randomize()
	add_child(tween)


func animate_reload_scene(duration := 0.3):
	if tween.is_active():
		return
	
	var tree := get_tree()
	var current_scene := tree.current_scene
	var packed_scene := load(current_scene.filename) as PackedScene
	var scene := packed_scene.instance() as Node
	
	var ok := true
	ok = tween.interpolate_property(current_scene, "modulate", Color.white, Color.transparent, duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	ok = tween.interpolate_deferred_callback(current_scene, duration, "queue_free")
	ok = tween.interpolate_callback(tree.root, duration, "add_child", scene)
	ok = tween.interpolate_callback(tree, duration, "set_current_scene", scene)
	ok = tween.interpolate_property(scene, "modulate", Color.transparent, Color.white, duration + duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	ok = tween.start()
	assert(ok)
