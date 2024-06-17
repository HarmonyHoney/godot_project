extends CanvasLayer

@onready var bar := $Control/Bar
@onready var notch := $Control/Notch
@export var dist := 250.0
@onready var label := $Control/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func move_notch(to := 0.0):
	to = clamp(to, -1, 1)
	notch.position = bar.position + Vector2(to * dist, 0.0)

func print_label(text := ""):
	label.text = text
