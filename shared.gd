extends Node

var look_sens := 0.01
var carve_sens := 1.50
var is_look := false
var is_look_toggle := true
var is_colshape := false : set = set_is_colshape
var is_reset := false : set = set_is_reset

func _input(event):
	if event.is_action_pressed("debug_reset"):
		get_tree().reload_current_scene()
	
	if event.is_action_pressed("cam_look"):
		is_look = !is_look if is_look_toggle else true
	if !is_look_toggle and event.is_action_released("cam_look"):
		is_look = false

func set_is_colshape(arg := false):
	is_colshape = arg
	get_tree().debug_collisions_hint = is_colshape
	print(get_tree().debug_collisions_hint)

func set_is_reset(arg := false):
	if arg:
		get_tree().call_deferred("reload_current_scene")
