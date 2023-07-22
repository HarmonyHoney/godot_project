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

func _physics_process(delta):
	is_floor = is_on_floor()
	btnp_jump = Input.is_action_just_pressed("jump")
	
	if is_floor:
		anim.play("Idle" if velocity == Vector3.ZERO else "Run")
	else:
		anim.play("Jump" if velocity.y > 0 else "Fall")
		# gravity
		velocity.y -= gravity * delta
	
	if btnp_jump and is_floor:
		velocity.y = jump_vel
		anim.play("Jump")
	
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (cam.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	velocity.x = (direction.x * walk_speed) if direction else move_toward(velocity.x, 0, walk_speed)
	velocity.z = (direction.z * walk_speed) if direction else move_toward(velocity.z, 0, walk_speed)
	
	if direction:
		model.rotation.y = atan2(velocity.x, velocity.z)
	
	move_and_slide()
