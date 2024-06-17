extends Node

var mouse_sens := 0.01
var carve_sens := 0.01
var is_look := false

func _input(event):
	if event.is_action_pressed("cam_look"):
		is_look = !is_look
