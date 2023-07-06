extends Node3D

@onready var audio = $"../../AudioStreamPlayer3D"
@onready var mesh = $".."

var color := Color(2, 0, 0, 1)
var hitColor := Color(5, 5, 1, 1)
var timer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	if timer > 0.2:
		timer = 0.0
		mesh.material_override.albedo_color = color
		

func hit():
	prints('target hit !')
	audio.pitch_scale = randf_range(1, 1.2)
	mesh.material_override.albedo_color = hitColor
	audio.play()
	#add albedo change on hit
