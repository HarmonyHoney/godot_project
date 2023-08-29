extends HBoxContainer

var value := 0.0

@onready var scrollbar := $HScrollBar
#@onready var label := $Label
@onready var line := $LineEdit

func _ready():
	scrollbar.scrolling.connect(scroll_test)
	line.text_submitted.connect(line_test)

func scroll_test():
	test(scrollbar.value)

func line_test(arg):
	test(float(arg))
	scrollbar.value = value

func test(arg):
	value = snappedf(arg, 0.01)
	line.text = str(value).pad_decimals(2)
	Shared.mouse_sens = value


