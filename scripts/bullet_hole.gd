extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	pass


func _on_timer_timeout():
	queue_free()

func _on_mesh_instance_3d_ready():
	await get_tree().create_timer(0.1).timeout
	$dust.emitting = true
	
