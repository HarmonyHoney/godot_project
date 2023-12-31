extends Node3D

@onready var cam := $Camera3D

@export var target_node : Node3D
@export var follow_offset := Vector3(0,0,0)
@export var follow_dist := 2.0

@export var sensitivity := 0.01
@export var angle := Vector2.ZERO


func _input(event):
	if event is InputEventMouseMotion and !Menu.is_open:
		var r = event.relative
		angle -= Vector2(r.y, r.x) * Shared.mouse_sens * 0.001
		var limit = PI * 0.499
		angle = Vector2(clamp(angle.x, -limit, limit), wrapf(angle.y, 0.0, TAU))

func _process(delta):
	position = target_node.position + follow_offset
	rotation = Vector3(angle.x, angle.y, 0.0)
