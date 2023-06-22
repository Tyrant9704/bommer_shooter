extends Control
@onready var main = $"."
@onready var optionsMenu = $OptionsMenuControl

var isOpened = true
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		toggleMenu()	
		
func toggleMenu():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		main.visible = true
	else:
		main.visible = false


func _on_quit_button_up():
	get_tree().quit()


func _on_options_button_up():
	optionsMenu.visible = true


func _on_back_button_button_up():
	optionsMenu.visible = false
