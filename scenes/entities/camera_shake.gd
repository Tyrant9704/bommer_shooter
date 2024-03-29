extends Camera3D

@export var max_x := 10.0
@export var max_y := 10.0
@export var max_z := 5.0
var _only_Y: bool

var trauma := 0.0

@export var trauma_reduction_rate := 1.0

@export var noise : FastNoiseLite

@export var noise_speed := 50.0

var noise_speed_modifier := 2

var time := 0.0


@onready var camera = $"." as Camera3D
@onready var init_rotation = camera.rotation_degrees as Vector3

func _ready():
	pass # Replace with function body.


func _process(delta):
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	
	camera.rotation_degrees.x = init_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
	if not _only_Y:
		camera.rotation_degrees.y = init_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1)
		camera.rotation_degrees.z = init_rotation.z + max_z * get_shake_intensity() * get_noise_from_seed(2)
	
	if trauma < 0.01:
		_only_Y = false
	
	
func add_trauma(trauma_amount : float, speed := 1, only_Y := false) -> void :
	_only_Y = only_Y
	noise_speed_modifier = speed
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)


func get_shake_intensity() -> float :
	return trauma * trauma


func get_noise_from_seed(_seed: int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed * noise_speed_modifier)
