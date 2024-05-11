extends CharacterBody3D

@onready var skateboard : Node3D = $Skateboard
@onready var deck := $Skateboard/Deck
@onready var axel1 := $Skateboard/Axel
@onready var axel2 := $Skateboard/Axel2

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
@export var push_mod := 0.7
@export var move_delta := 0.5
@export var lean_angle := 0.25
@export var turn_angle := 0.1
@export var carve_boost := 0.1

var floor_angle = 0.0

var last_turn := 0.0
var turn_dir := 0.0
var turn_diff := 0.0

func _physics_process(delta):
	
	is_floor = is_on_floor()
	btnp_jump = Input.is_action_just_pressed("jump")
	btn_push = Input.is_action_pressed("push")
	btnp_push = Input.is_action_just_pressed("push")
	
	if is_floor:
		floor_angle = angle
		# pushing
		if btnp_push and vel < push_speed:
			vel = lerp(vel, push_speed, push_mod)
	else:	
		# gravity
		velocity.y -= gravity * delta
	
	if btnp_jump and is_floor:
		velocity.y = jump_vel
		#anim.play("Jump")
	
	
	# turn
	var input_dir = Input.get_vector("left", "right", "up", "down")
	last_turn = turn_dir
	turn_dir = input_dir.x
	turn_diff = abs(turn_dir - last_turn)
	
	angle -= turn_dir * turn_speed  * vel
	skateboard.rotation.y = angle + PI
	axel1.rotation.y = -turn_dir * turn_angle
	axel2.rotation.y = turn_dir * turn_angle
	# lean
	deck.rotation.z = turn_dir * lean_angle
	
	
	vel *= 1.0 + (turn_diff * carve_boost)
	vel = move_toward(vel, 0.0, move_delta)
	
	
	var go = Vector3.FORWARD.rotated(Vector3(0,1,0), floor_angle) * vel
	
	velocity.x = go.x
	velocity.z = go.z
	
	
	
	
	move_and_slide()
	
	var after = Vector3(velocity.x, 0, velocity.z).length()
	vel = after
