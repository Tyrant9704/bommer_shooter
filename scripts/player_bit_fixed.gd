extends CharacterBody3D


var speed = 0
var acceleration = 6
const DEFAULT_SPEED = 10.0
const RUN_SPEED = 22.0
const CROUCH_SPEED = 6.0

const RUN_FOV = 70.0
const WALK_FOV = 60.0
const ZOOM_FOV = 40.0

const DEFAULT_JUMP_VELOCITY = 15.0
var JUMP_VELOCITY = 15.0

const MAX_WALLJUMPS = 2
const MAX_WALLJUMPS_SPRINTING = 5
var walljumps = 2

#shooting sfuff
var next_shot = true
var reloaded = true
var max_ammo = 35
var mag = 7
const mag_size = 7

# is changing depending from the player state
var player_state = 'idle'
var aim_state = 'not_aim'
var player_pos = 'stand'

#const player_height_standing = 2
#const player_height_crouching = 0.5


const MOUSE_SENSITIVITY = 0.1

# jetpack variables
var maxJetpackEnergy = 100
var currentJetpackEnergy = 100
var jetpackRegenRate = 0.9
var jetpackThrust = 1
var canFly = true
var jetpackEnabled = false
var jetpack_hold = 0.0
const hold_time = 0.3

var timer = Timer.new()
var effect = Vector3(0, -5, -5)
var cameraZoom = 0.0



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 4 # multiplied by four xd

@onready var neck := $head
@onready var camera := $head/Camera3D
@onready var anim = $AnimationPlayer
@onready var player_capsule = $Player_collision
@onready var ladder = $"../ladder"
@onready var ladder_raycast = $ladder_raycast
@onready var bullet_origin = $head/Camera3D/bullet_origin
@onready var bullet_hole = preload("res://scenes/bullet_hole.tscn")
#ui ? ?? 
@onready var jetpackLabel = $head/Camera3D/Control/jetpack_label
@onready var ammo_count = $head/Camera3D/Control/ammo_count
# dziala to?  xd
#func update_jetpackLabel_col():
#	jetpackLabel.label_settings.font_color = currentJetpackEnergy
	

func _input(event):
	
#----mouse_input-----
	
	if Input.is_action_just_pressed("ui_cancel"): #esc key
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			# enable ingame HUD
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			# disable ingame HUD
			# add menu screen UI
		
	#handle first person rotations
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x) * MOUSE_SENSITIVITY)
			neck.rotate_x(deg_to_rad(-event.relative.y) * MOUSE_SENSITIVITY)
			neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-90), deg_to_rad(90))



func _process(delta):
#----- whatever the fuck is this----
	var anim_state = player_state + player_pos + aim_state
	
	$AnimationTree.set("parameters/Transition/transition_request", anim_state )
	
	
	#for shooting stuff & shit
	if Input.is_action_just_pressed('jetpack') and reloaded:
		reloaded = false
		print(reloaded)
		$AnimationPlayer.play("reload")
		if reloaded == false:
			mag = mag_size
			max_ammo -= mag_size
		
		
	if Input.is_action_just_pressed("LMB") and next_shot:
		mag -= 1
		if mag >= 0:
			next_shot = true
		else:
			next_shot = false
			
		# Handle sprint & shit
	if speed == 10:
		player_state = 'walk'
	if Vector3.ZERO == self.get_velocity():
		player_state = 'idle'
	if Input.is_action_pressed("sprint"):
		player_state = 'sprint'
	if Input.is_action_just_released('sprint'):
		player_state = 'walk'
	if Input.is_action_pressed("crouch"):
		player_pos = 'crouch'
		speed = CROUCH_SPEED
	else:
		player_pos = 'stand'

	if player_state == 'idle':
		cameraZoom = 0;
		#cameraZoom has to be less than 1, else it causes weird errors (probably extrapolation)
	elif cameraZoom < 1:
		cameraZoom += delta * 3
	
	if player_state == 'sprint':
		if Input.is_action_pressed("forward"):
			speed = RUN_SPEED
			camera.fov = lerp(camera.fov, RUN_FOV, cameraZoom)
			camera.fov = clamp(camera.fov, WALK_FOV, RUN_FOV)
	else:
		speed = DEFAULT_SPEED
		camera.fov = WALK_FOV
	
		#mouse zoom
	if Input.is_action_pressed("RMB"):
		aim_state = 'aim'
		camera.fov = ZOOM_FOV
	else:
		aim_state = 'not_aim'
	if Input.is_action_just_released("RMB"):
		aim_state = 'not_aim'
			

#----jetpack & ammo-----
	jetpackLabel.set_text("jetpack: " + var_to_str(floor(currentJetpackEnergy)) + " %")
	ammo_count.set_text('Ammo' + ' ' + var_to_str((max(0,mag)))+ '/' + var_to_str(max(0, max_ammo)))
	
	if Input.is_action_pressed("jump"):
		if not is_on_floor():
			jetpack_hold += delta
			if jetpack_hold >= hold_time:
				jetpackEnabled = true
		else: 
			jetpackEnabled = false 
			jetpack_hold = 0.0
	
	# jetpack energy recharge
	if is_on_floor() or not jetpackEnabled:
		if(currentJetpackEnergy <= maxJetpackEnergy):
			currentJetpackEnergy += jetpackRegenRate
			
	
	if currentJetpackEnergy <= 0:
		currentJetpackEnergy = 0
		canFly = false
	else:
		canFly = true
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
		if Input.is_action_pressed("jump") and canFly and jetpackEnabled:
			velocity.y += jetpackThrust
			currentJetpackEnergy -= 1
#---jetpack----

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		#prints(velocity)
		
	# Handle walljumps
	#decrease height of the subsequent jumps over time !!! this will improve
	# weird feeling of unlimited jumpiness XD
	#so if player wants to jump high, or wallrun, it has to be done fast and
	#and with momentum, not jump, coffe break, jump, scratching butt, jump...
	# - delta * 3 maybe ? some timer here like with fov zoom out
	elif Input.is_action_just_pressed("jump") and is_on_wall() and walljumps > 0:
		velocity.y = JUMP_VELOCITY
		#simplified version
		JUMP_VELOCITY -= 2.5
		walljumps -= 1
		#prints(JUMP_VELOCITY)

	#reset walljumps couner
	if is_on_floor():
		
		if player_state == 'sprint':
			walljumps = MAX_WALLJUMPS_SPRINTING
		else:
			walljumps = MAX_WALLJUMPS
	
		JUMP_VELOCITY = DEFAULT_JUMP_VELOCITY

	# ----------------------------------------------------------------------

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
			#velocity.x = direction.x * speed
			#velocity.z = direction.z * speed
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 4)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 4)

	else:
		if not is_on_floor():
			velocity.x = move_toward(velocity.x, 0, speed * delta * 0.5)
			velocity.z = move_toward(velocity.z, 0, speed * delta * 0.5)
		else:	
			velocity.x = move_toward(velocity.x, 0, speed * delta * 6)
			velocity.z = move_toward(velocity.z, 0, speed * delta * 6)

	
			
#whatever the fuck is this doing right here----------
	move_and_slide()
#anoher whatever the fuck raycast
	#raycast origin
	bullet_origin.transform.origin = $head/Camera3D.transform.origin
	#rest of it
	if reloaded and next_shot:
		if Input.is_action_just_pressed("LMB"):
			var collider = bullet_origin.get_collider()
			if bullet_origin.get_collision_mask_value(5):
				if bullet_origin.is_colliding():
					$AnimationPlayer.play("shoot")
					$"head/Camera3D/arms&shit/gun/CPUParticles3D".restart()
					$"head/Camera3D/arms&shit/gun/CPUParticles3D".emitting = true
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
				


func _on_animation_player_animation_finished(reload):
	next_shot = true
	reloaded = true
