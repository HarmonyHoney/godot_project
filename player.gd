extends RigidBody3D

@onready var center : Node3D = $Center
@onready var skateboard : Node3D = $Center/Skateboard
@onready var deck := $Center/Skateboard/Deck
@onready var axel1 := $Center/Skateboard/Axels/Axel
@onready var axel2 := $Center/Skateboard/Axels/Axel2

@onready var ray_node := $Ray
@onready var debug_ray1 := $Ray/Cast1
@onready var debug_ray2 := $Ray/Cast2
@onready var debug_ray3 := $Ray/Cast3
@onready var debug_ray4 := $Ray/Cast4

@onready var rayboard := $Ray/Board
@onready var rayboard1 := $Ray/Board/Ray1
@onready var rayboard2 := $Ray/Board/Ray2
@onready var last_rayboard := Vector3.ZERO

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
@export var turn_brake := 1.0
@export var push_speed := 5.0
@export var lean_angle := 0.25
@export var turn_angle := 0.1
@export var carve_boost := 0.1

var last_turn := 0.0
var turn_dir := 0.0
var turn_diff := 0.0
@export var turn_lerp := 12.0
@export var power_lerp := 2.0
@export var curvy : Curve
@export var mouse_sens := 0.001
@export var powerslide_degrees := 33.0
@export var max_vel_length := 100.0

var mouse_vel := Vector2.ZERO

var mouse_lean := 0.0

var velocity := Vector3.ZERO

var last_hit := Vector3.ZERO
var last_normal := Vector3.ZERO
var last_dist := 0.0
var last_from := Vector3.ZERO

var last_1 := 0.0
var last_2 := 0.0

func _input(event):
	if event is InputEventMouseMotion:
		mouse_vel = event.relative
	
	if event.is_action_pressed("debug_reset"):
		get_tree().reload_current_scene()
	

func _physics_process(delta):
	velocity = linear_velocity
	
	var q = PI * 0.5
	var cam_dist = wrapf(cam.angle.y + q - angle, -PI, PI)
	var cam_float = 1 if cam_dist < 0 else -1
	var vang = wrapf(atan2(velocity.x, velocity.z), 0.0, TAU)
	var dang = wrapf(vang - angle, -q, q)
	var ad = rad_to_deg(abs(dang))
	var frac = ad / 90.0
	var unfrac = 1.0 - frac
	
	is_floor = debug_ray3.is_colliding()#false #is_on_floor()
	btnp_jump = Input.is_action_just_pressed("jump")
	btn_push = Input.is_action_pressed("push")
	btnp_push = Input.is_action_just_pressed("push")
	btn_brake = Input.is_action_pressed("brake")
	
	# turn
	var input_dir = Input.get_vector("left", "right", "up", "down")
	
	#input_dir.x = ease(abs(input_dir.x), 5.0) * sign(input_dir.x)
	
	# mouse control
	if !Shared.is_look:
		input_dir.x = clamp(mouse_vel.x * Shared.carve_sens * mouse_sens, -1.0, 1.0)
		#mouse_lean = clamp(mouse_lean + (mouse_vel.x * Shared.carve_sens * mouse_sens), -1.0, 1.0)
		#input_dir.x = mouse_lean
	
	UI.move_notch(input_dir.x)
	
	last_turn = turn_dir
	turn_dir = input_dir.x
	turn_diff = abs(turn_dir - last_turn)
	
	angle -= turn_dir * (turn_brake if btn_brake else turn_speed) * min(velocity.length(), max_vel_length) * delta
	angle = wrapf(angle, 0.0, TAU)
	var ffloor = float(is_floor)
	axel1.rotation.y = -turn_dir * turn_angle * cam_float * ffloor 
	axel2.rotation.y = turn_dir * turn_angle * cam_float * ffloor
	# lean
	deck.rotation.z = turn_dir * lean_angle * cam_float * ffloor
	
	
	if is_floor:
		# turn velocity
		if !btn_brake:
			velocity = velocity.rotated(Vector3(0,1,0), -dang * turn_lerp * unfrac * delta)
		
		# carve boost
		var vel_flat = Vector3(velocity.x, 0, velocity.z)
		velocity += vel_flat * carve_boost * turn_diff
		
		# powerslide
		if ad > powerslide_degrees:
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
	
	ray_node.global_rotation = Vector3.ZERO
	# velocity
	debug_ray1.target_position = velocity.normalized() * 5.0
	# angle
	debug_ray2.target_position = Vector3(0, 0, 5.0).rotated(Vector3(0,1,0), angle)
	
	
	center.global_rotation = Vector3.ZERO
	
	if is_floor:
		last_hit = debug_ray3.get_collision_point()
		last_normal = debug_ray3.get_collision_normal()
		last_dist = last_from.distance_to(last_hit)
		
		debug_ray4.global_position = last_hit
		debug_ray4.target_position = last_normal * 3.0
		
		
		
	
	
	rayboard.rotation.y = angle
	skateboard.rotation.y = angle
	
	var middle = 0.0
	var ang = 0.0
	
	if rayboard1.is_colliding() and rayboard2.is_colliding():
		last_1 = last_rayboard.y - rayboard1.get_collision_point().y
		last_2 = last_rayboard.y - rayboard2.get_collision_point().y
		middle = lerp(last_1, last_2, 0.5)
		last_dist = 1.12 - middle
		ang = (rayboard1.global_position + rayboard1.get_collision_point()).angle_to(rayboard2.global_position + rayboard2.get_collision_point())
		skateboard.rotation.x = ang
	else:
		var l = 3.0
		last_dist = lerp(last_dist, 0.0, l * delta)
		skateboard.rotation.x = lerp(skateboard.rotation.x, 0.0, l * delta)
	
	
	skateboard.position.y = last_dist
	
	
	linear_velocity = velocity
	
	var s = ""
	s += "speed: " + str(velocity.length())
	s += "\nturn diff: " + str(turn_diff)
	s += "\nlast_1: " + str(last_1)
	s += "\nlast_2: " + str(last_2)
	s += "\nmiddle: " + str(middle)
	s += "\nang: " + str(ang)
	
	
	UI.print_label(s)
	
	mouse_vel = Vector2.ZERO
	last_from = debug_ray3.global_position
	last_rayboard = rayboard.global_position
