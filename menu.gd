extends CanvasLayer

var is_open := false

func _ready():
	open(false)

func _input(event):
	if event.is_action_pressed("ui_menu"):
		open()
		
func _process(delta):
	pass

func open(_is_open = !is_open):
	is_open = _is_open
	visible = is_open
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if is_open else Input.MOUSE_MODE_CAPTURED
	
