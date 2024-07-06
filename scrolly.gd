extends HBoxContainer

var value = 13.27

@export var var_name := "look_sens"

@export var scrollbar_path : NodePath = ""
@onready var scrollbar := get_node_or_null(scrollbar_path)

@export var line_edit_path : NodePath = ""
@onready var line_edit := get_node_or_null(line_edit_path)

@export var check_button_path : NodePath = ""
@onready var check_button := get_node_or_null(check_button_path)

func _ready():
	if scrollbar:
		scrollbar.scrolling.connect(scroll_test)
		scroll_test()
	if line_edit:
		line_edit.text_submitted.connect(line_test)
		line_test(line_edit.text)
	if check_button:
		check_button.toggled.connect(check_toggle)
		check_toggle(check_button.button_pressed)

func scroll_test():
	if scrollbar:
		test(scrollbar.value)

func line_test(arg):
	test(float(arg))
	if scrollbar:
		scrollbar.value = value

func test(arg):
	value = snappedf(arg, 0.01)
	line_edit.text = str(value).pad_decimals(2)
	assign()

func check_toggle(arg := false):
	value = arg
	check_button.text = str(value)
	assign()

func assign():
	Shared.set(var_name, value)

