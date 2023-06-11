extends Node3D

@onready var raycast_container = $raycast_container
@onready var bullet_origin = $"../../Camera3D/raycast_origin"
@onready var ray_container = $raycast_container

var spread = 10

func _ready():
	_spread()

func _process(delta):
	raycast_container.global_transform.origin = bullet_origin.global_transform.origin
	raycast_container.global_rotation = bullet_origin.global_rotation

func _spread():
	for r in ray_container.get_children():
		r.target_position.x = randf_range(spread, -spread)
		r.target_position.y = randf_range(spread, -spread)
		
