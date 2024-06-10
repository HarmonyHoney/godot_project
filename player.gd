extends CharacterBody3D

@onready var skateboard : Node3D = $Skateboard
@onready var deck := $Skateboard/Deck
@onready var axel1 := $Skateboard/Axel
@onready var axel2 := $Skateboard/Axel2

@onready var debug_ray1 := $RayCast3D
@onready var debug_ray2 := $RayCast3D2

@export var jump_vel = 4.5
@export var cam : Node

var gravity = 9.8
var is_floor := false
var btn_jump := false
var btnp_jump := false
var btn_push := false
var btnp_push := false
var btn_brake := false
var btn_look := false
var btnp_look := false

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
@export var mouse_sens := 1.0

var mouse_vel := Vector2.ZERO
var mouse_stance := 1.0

func _input(event):
	if event is InputEventMouseMotion:
		mouse_vel = event.relative
	
	if event.is_action_pressed("debug_reset"):
		get_tree().reload_current_scene()

func _physics_process(delta):
	var q = PI * 0.5
	var cam_dist = wrapf(cam.angle.y + q - angle, -PI, PI)
	var cam_float = 1 if cam_dist < 0 else -1
	var vang = wrapf(atan2(velocity.x, velocity.z), 0.0, TAU)
	var dang = wrapf(vang - angle, -q, q)
	var ad = rad_to_deg(abs(dang))
	var frac = ad / 90.0
	var unfrac = 1.0 - frac
	
	is_floor = is_on_floor()
	btnp_jump = Input.is_action_just_pressed("jump")
	btn_push = Input.is_action_pressed("push")
	btnp_push = Input.is_action_just_pressed("push")
	btn_brake = Input.is_action_pressed("brake")
	btn_look = Input.is_action_pressed("cam_look")
	btnp_look = Input.is_action_just_pressed("cam_look")
	
	# turn
	var input_dir = Input.get_vector("left", "right", "up", "down")
	# mouse control
	if btn_look:
		if btnp_look:
			mouse_stance = 1.0#cam_float
		input_dir.x = clamp(mouse_vel.x * mouse_sens * mouse_stance, -1.0, 1.0)
		#cam.angle.y = angle
	
	last_turn = turn_dir
	turn_dir = lerp(turn_dir, input_dir.x, carve_lerp * delta)
	turn_diff = abs(turn_dir - last_turn)
	
	angle -= turn_dir * turn_speed * velocity.length() * delta
	angle = wrapf(angle, 0.0, TAU)
	skateboard.rotation.y = angle
	var ffloor = float(is_floor)
	axel1.rotation.y = -turn_dir * turn_angle * ffloor
	axel2.rotation.y = turn_dir * turn_angle * ffloor
	# lean
	deck.rotation.z = turn_dir * lean_angle
	
	if is_floor:
		# turn
		velocity = velocity.rotated(Vector3(0,1,0), -dang * turn_lerp * curvy.sample(unfrac) * delta)
		
		# powerslide
		if ad > 33:
			velocity = velocity * (1.0 - (frac * power_lerp * delta))
		elif btn_brake:
			velocity = velocity * (1.0 - (1.0 * power_lerp * delta))
		
		# pushing
		if btnp_push:
			velocity += (Vector3(0,0,cam_float) * push_speed).rotated(Vector3(0,1,0), angle)
			debug_ray2.scale = Vector3.ONE * cam_float
		
		# jump
		if btnp_jump:
			velocity.y = jump_vel
	else:
		# gravity
		velocity.y -= gravity * delta
	
	print(rad_to_deg(angle), " - ", rad_to_deg(vang), " = ", rad_to_deg(dang), " , ", frac, " cam: ", rad_to_deg(cam_dist))
	
	# velocity
	debug_ray1.target_position = velocity.normalized() * 5.0
	# angle
	debug_ray2.target_position = Vector3(0, 0, 5.0).rotated(Vector3(0,1,0), angle)
	
	move_and_slide()
