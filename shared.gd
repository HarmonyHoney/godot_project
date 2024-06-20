extends Node

var look_sens := 0.01
var carve_sens := 1.50
var is_look := false
var is_look_toggle := true

func _input(event):
	if event.is_action_pressed("cam_look"):
		is_look = !is_look if is_look_toggle else true
	if !is_look_toggle and event.is_action_released("cam_look"):
		is_look = false
