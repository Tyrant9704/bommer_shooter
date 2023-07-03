extends RigidBody3D

var entered = true


func _on_timer_timeout():
	queue_free()


func _on_body_entered(_body):
	if entered:
		$AudioStreamPlayer.play()
		entered = false
