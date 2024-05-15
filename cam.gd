extends Node3D

@onready var cam := $Camera3D

@export var target_node : Node3D
@export var follow_offset := Vector3(0,0,0)
@export var follow_dist := 2.0

@export var angle := Vector2.ZERO
@export var joy_sens := 1.0

var is_look := false

func _input(event):
	if event is InputEventMouseMotion and !Menu.is_open and !is_look:
		var r = event.relative
		angle -= Vector2(r.y, r.x) * Shared.mouse_sens * 0.001
		var limit = PI * 0.499
		angle = Vector2(clamp(angle.x, -limit, limit), wrapf(angle.y, 0.0, TAU))

func _process(delta):
	is_look = Input.is_action_pressed("cam_look")
	var joy = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if joy:
		angle += -Vector2(joy.y, joy.x) * joy_sens * delta
		var limit = PI * 0.499
		angle = Vector2(clamp(angle.x, -limit, limit), wrapf(angle.y, 0.0, TAU))
	
	position = target_node.position + follow_offset
	rotation = Vector3(angle.x, angle.y, 0.0)
