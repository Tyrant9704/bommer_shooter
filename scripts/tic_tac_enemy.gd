extends RigidBody3D

var health = 100

# Called when the node enters the scene tree for the first time.
func _health(health_amount):
	
	print(health)
	health -= health_amount
	if health <= 0:
		$AudioStreamPlayer3D.play()
		visible = false


func _on_audio_stream_player_3d_finished():
	queue_free()
