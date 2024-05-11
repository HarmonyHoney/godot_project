extends CharacterBody3D

@onready var model : Node3D = $GobotSkin
@onready var anim : AnimationPlayer = $GobotSkin/gobot/AnimationPlayer

@export var walk_speed = 5.0
@export var jump_vel = 4.5
@export var cam : Node

var gravity = 9.8
var is_floor := false
var btn_jump := false
var btnp_jump := false
var btn_push := false
var btnp_push := false
var angle := 0.0
var vel := 0.0
@export var turn_speed := 1.0
@export var push_speed := 5.0
@export var move_delta := 0.5
@export var lean_angle := 0.25


var air_angle := 0.0
var floor_angle = 0.0

func _physics_process(delta):
	
	is_floor = is_on_floor()
	btnp_jump = Input.is_action_just_pressed("jump")
	btn_push = Input.is_action_pressed("push")
	btnp_push = Input.is_action_just_pressed("push")
	
	if is_floor:
		floor_angle = angle
		# pushing
		if btnp_push:
			vel = min(push_speed * 3.0, vel + push_speed)
	else:	
		# gravity
		velocity.y -= gravity * delta
	
	if btnp_jump and is_floor:
		velocity.y = jump_vel
		anim.play("Jump")
		air_angle = angle
	
	
	
	vel = move_toward(vel, 0.0, move_delta)
	
	
	# turn
	var input_dir = Input.get_vector("left", "right", "up", "down")
	angle -= input_dir.x * turn_speed  * vel
	model.rotation.y = angle + PI
	# lean
	model.rotation.z = input_dir.x * lean_angle
	
	
	
	var go = Vector3.FORWARD.rotated(Vector3(0,1,0), floor_angle) * vel
	
	velocity.x = go.x
	velocity.z = go.z
	
	
	
	
	move_and_slide()
	
	var after = Vector3(velocity.x, 0, velocity.z).length()
	vel = after
