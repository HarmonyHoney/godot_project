extends Node3D

@onready var cam := $Camera3D

@export var target_node : Node3D
@export var follow_offset := Vector3(0,0,0)

@export var angle := Vector2.ZERO
@export var joy_sens := 1.0
@export var lerp_angle := Vector2.ONE
@export var resting_yaw := 30.0

@export var scroll_speed := 0.1
@export var max_zoom := 10.0

func _input(event):
	if Menu.is_open: return
	
	if event is InputEventMouseMotion and Shared.is_look:
		var r = event.relative
		angle -= Vector2(r.y, r.x) * Shared.look_sens * 0.001
		var limit = PI * 0.499
		angle = Vector2(clamp(angle.x, -limit, limit), wrapf(angle.y, 0.0, TAU))
	
	var zi = event.is_action_pressed("zoom_in")
	var zo = event.is_action_pressed("zoom_out")
	if zi or zo:
		cam.position.z = clamp(cam.position.z + scroll_speed * (-1 if zi else 1), 0.0, max_zoom)

func _process(delta):
	var joy = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if joy:
		angle += -Vector2(joy.y, joy.x) * joy_sens * delta
		var limit = PI * 0.499
		angle = Vector2(clamp(angle.x, -limit, limit), wrapf(angle.y, 0.0, TAU))
	
	position = target_node.global_position + follow_offset
	
	var vel = target_node.velocity
	var ang = atan2(vel.x, vel.z)
	if vel.length() > 3.0 and !Shared.is_look:
		angle.x = lerp_angle(angle.x, deg_to_rad(resting_yaw), delta * lerp_angle.x )
		angle.y = lerp_angle(angle.y, ang + PI, delta * lerp_angle.y)
	rotation = Vector3(angle.x, angle.y, 0.0)
