extends Node3D


@onready var mesh := $MeshInstance3D

var color = Color(2, 0, 0, 1)
var hitColor = Color(5, 5, 1, 1)


func _target_hit():
	mesh.material_override.albedo_color = hitColor

	await get_tree().create_timer(0.3).timeout
	mesh.material_override.albedo_color = color
	

