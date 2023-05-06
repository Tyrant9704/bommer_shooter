extends Node3D

@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree

var next_shot = true
var reloaded = true

var max_ammo = 35
var mag = 7
const mag_size = 7

var effect = Vector3(0, -5, -10)
@onready var bullet_hole = preload("res://scenes/env/bullet_hole.tscn")

var aim_state = 'not_aim'

@onready var bullet_origin = get_parent().get_node("../bullet_origin")




func _ready():
	pass # Replace with function body.


func _process(delta):
	
	
#anim handler
	var anim_state = global_script.player_state + '_' + global_script.player_pos + '_' + aim_state
	$AnimationTree.set('parameters/Transition/transition_request', anim_state )
	#for shooting stuff & shit
	if Input.is_action_just_pressed('jetpack') and reloaded:
		reloaded = false
		print(reloaded)
		$AnimationPlayer.play("m1911_anims/reload")
		if reloaded == false:
			mag = mag_size
			max_ammo -= mag_size
			
		
		
	if Input.is_action_just_pressed("LMB") and next_shot:
		mag -= 1
		if mag >= 0:
			next_shot = true
		else:
			next_shot = false
	
	if Input.is_action_pressed("RMB"):
		aim_state = 'aim'
	else:
		aim_state = 'not_aim'
	if Input.is_action_just_released("RMB"):
		aim_state = 'not_aim'	

	if reloaded and next_shot:
		if Input.is_action_just_pressed("LMB"):
			var collider = bullet_origin.get_collider()
			if bullet_origin.get_collision_mask_value(5):
				if bullet_origin.is_colliding():
					$AnimationPlayer.play("m1911_anims/shoot")
					$"arms&shit/gun/CPUParticles3D".restart()
					$"arms&shit/gun/CPUParticles3D".emitting = true
					next_shot = false
					if collider is RigidBody3D:
						collider.apply_central_impulse(self.global_transform.basis * effect)
					if collider and 'enemy' in collider.get_groups():
						collider._health(20)
						pass
					else:
						var b_hole = bullet_hole.instantiate()
						collider.add_child(b_hole)
						b_hole.global_transform.origin = bullet_origin.get_collision_point()
						b_hole.look_at(bullet_origin.get_collision_point() + bullet_origin.get_collision_normal(), Vector3.UP)
				
	
func _on_animation_player_animation_finished(m1911_animsreload):
	reloaded = true
	next_shot = true
