extends Node3D

@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree

var next_shot = true
var reloaded = true

var max_ammo = 35
var mag = 7
const mag_size = 7

var effect = Vector3(0, -5, 10)
@onready var bullet_hole = preload("res://scenes/env/bullet_hole.tscn")

var aim_state = 'not_aim'

@onready var bullet_origin = get_parent().get_node("../bullet_origin")

# we should probably move it to some ui controller in the future
@onready var ammoCountLabel = $"../../Control/ammo_count"


func updateAmmoLabel():
	ammoCountLabel.set_text("Ammo " + var_to_str(mag) + ' / ' + var_to_str(max_ammo))


func _ready():
	pass # Replace with function body.
	

func _process(delta):
	
	# self explainatory		
	updateAmmoLabel()
	
#anim handler
	var anim_state = global_script.player_state + '_' + global_script.player_pos + '_' + aim_state
	$AnimationTree.set('parameters/Transition/transition_request', anim_state )
	#for shooting stuff & shit
	if global_script.player_state == 'sprint':
		next_shot = false
	else:
		next_shot = true
		
	if Input.is_action_just_pressed('reload') and reloaded:
		next_shot = false
		# prevent reloading when mag is full or no ammo left
		if mag == mag_size or max_ammo <= 0:
			return
		$AnimationPlayer.play("m1911V3/tactical_reload")
		reloaded = false
		if mag == 0:
			anim_player.play("m1911V3/full_reload")
		
		
		# lets calculate how many bullets the mag is missing and then...		
#		bullets to load = max mag size - current mag bullets
		var bulletsToLoad = mag_size - mag
		
		if reloaded == false:
			#mag = mag_size
			#max_ammo -= mag_size
			
			if max_ammo >= bulletsToLoad:
				mag += bulletsToLoad
				max_ammo -= bulletsToLoad
			else:
				mag += max_ammo
				max_ammo = 0
		
		
	if Input.is_action_just_pressed("LMB") and next_shot:
		if mag > 0:
			mag -= 1
			next_shot = true
		else:
			next_shot = false
	
	if Input.is_action_pressed("RMB"):
		aim_state = 'aim'
	else:
		aim_state = 'not_aim'
		

	if reloaded and next_shot:
		if Input.is_action_just_pressed("LMB"):
			var collider = bullet_origin.get_collider()
			$AnimationPlayer.play("m1911V3/shoot")
			$Skeleton3D/BoneAttachment3D/M1911/GPUParticles3D.restart()
			$Skeleton3D/BoneAttachment3D/M1911/GPUParticles3D.emitting
			next_shot = false
			if bullet_origin.get_collision_mask_value(5):
				if bullet_origin.is_colliding():
					next_shot = true
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
				
	
func _on_animation_player_animation_finished(is_that_even_matter):
	reloaded = true
	next_shot = true
