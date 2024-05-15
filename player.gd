extends CharacterBody3D

@onready var skateboard : Node3D = $Skateboard
@onready var deck := $Skateboard/Deck
@onready var axel1 := $Skateboard/Axel
@onready var axel2 := $Skateboard/Axel2

@export var jump_vel = 4.5
@export var cam : Node

var gravity = 9.8
var is_floor := false
var btn_jump := false
var btnp_jump := false
var btn_push := false
var btnp_push := false
var btn_brake := false
var angle := 0.0
@export var turn_speed := 1.0
@export var push_speed := 5.0
@export var lean_angle := 0.25
@export var turn_angle := 0.1
@export var carve_boost := 0.1

var last_turn := 0.0
var turn_dir := 0.0
var turn_diff := 0.0
@export var carve_lerp = 15.0
@export var turn_lerp := 12.0
@export var power_lerp := 2.0
@export var curvy : Curve

func _physics_process(delta):
	
	is_floor = is_on_floor()
	btnp_jump = Input.is_action_just_pressed("jump")
	btn_push = Input.is_action_pressed("push")
	btnp_push = Input.is_action_just_pressed("push")
	btn_brake = Input.is_action_pressed("brake")
	
	if is_floor:
		# pushing
		if btnp_push:
			velocity += (Vector3.BACK * push_speed).rotated(Vector3(0, 1, 0), angle)
	else:	
		# gravity
		velocity.y -= gravity * delta
	
	if btnp_jump and is_floor:
		velocity.y = jump_vel
		#anim.play("Jump")
	
	
	# turn
	var input_dir = Input.get_vector("left", "right", "up", "down")
	last_turn = turn_dir
	turn_dir = lerp(turn_dir, input_dir.x, carve_lerp * delta)
	turn_diff = abs(turn_dir - last_turn)
	
	angle -= turn_dir * turn_speed * velocity.length() * delta
	angle = wrapf(angle, 0.0, TAU)
	skateboard.rotation.y = angle
	axel1.rotation.y = -turn_dir * turn_angle
	axel2.rotation.y = turn_dir * turn_angle
	# lean
	deck.rotation.z = turn_dir * lean_angle
	
	var vang = wrapf(atan2(velocity.x, velocity.z), 0.0, TAU)
	var q = PI * 0.5
	var dang = wrapf(vang - angle, -q, q)
	var ad = rad_to_deg(abs(dang))
	var frac = ad / 90.0
	var unfrac = 1.0 - frac
	
	if is_floor:
		# turn
		velocity = velocity.rotated(Vector3(0,1,0), -dang * turn_lerp * curvy.sample(unfrac) * delta)
		
		# powerslide
		if ad > 33:
			velocity = velocity * (1.0 - (frac * power_lerp * delta))
		elif btn_brake:
			velocity = velocity * (1.0 - (1.0 * power_lerp * delta))
	
	print(rad_to_deg(angle), " - ", rad_to_deg(vang), " = ", rad_to_deg(dang), " , ", frac)
	
	# velocity
	$RayCast3D.target_position = velocity.normalized() * 5.0
	# angle
	$RayCast3D2.target_position = Vector3(0, 0, 5.0).rotated(Vector3(0,1,0), angle)
	
	move_and_slide()
