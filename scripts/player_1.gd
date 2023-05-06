extends CharacterBody3D


var speed
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

# change it to enum state
var isSprinting = false
var isCrouching = false
var isSliding = false

#const player_height_standing = 2
#const player_height_crouching = 0.5


const MOUSE_SENSITIVITY = 0.1

# jetpack variables
var maxJetpackEnergy = 100
var currentJetpackEnergy = 100
var jetpackRegenRate = 0.2
var jetpackThrust = 0.5
var canFly = true
var jetpackEnabled = false

var cameraZoom = 0.0



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 4 # multiplied by four xd

@onready var neck := $head
@onready var camera := $head/Camera3D
@onready var anim_play = $head/Camera3D/AnimationPlayer
@onready var slide_anim = $slideAnimation
@onready var player_capsule = $Player_collision
@onready var ladder = $"../ladder"
@onready var ladder_raycast = $ladder_raycast

#ui ? ?? 
@onready var jetpackLabel = $head/Camera3D/Control/jetpack_label
# dziala to?  xd
#func update_jetpackLabel_col():
#	jetpackLabel.label_settings.font_color = currentJetpackEnergy
	

func _input(event):
	
	# handle menu screen, capture / release mouse 
	
	if Input.is_action_just_pressed("ui_cancel"):
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
		


func _physics_process(delta):
	
	jetpackLabel.set_text("jetpack: " + str( round(currentJetpackEnergy) ) + "%")
	
	#sprinting zoom delta time
	if not isSprinting:
		cameraZoom = 0;
		#cameraZoom has to be less than 1, else it causes weird errors (probably extrapolation)
	elif cameraZoom < 1:
		cameraZoom += delta * 3
	
	speed = DEFAULT_SPEED
	camera.fov = WALK_FOV
	
	if Input.is_action_just_pressed("jetpack") and not jetpackEnabled:
		jetpackEnabled = true
	elif Input.is_action_just_pressed("jetpack") and jetpackEnabled:
		jetpackEnabled = false
	
	#mouse zoom
	if Input.is_action_pressed("RMB"):
		pass
		camera.fov = ZOOM_FOV
		
	# jetpack energy recharge
	if is_on_floor() or not jetpackEnabled:
		if(currentJetpackEnergy <= maxJetpackEnergy):
			currentJetpackEnergy += jetpackRegenRate
		
	
	if currentJetpackEnergy <= 0:
		canFly = false
	else:
		canFly = true
		
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
		if Input.is_action_pressed("jump") and canFly and jetpackEnabled:
			velocity.y += jetpackThrust
			currentJetpackEnergy -= 1

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
		
		if isSprinting:
			walljumps = MAX_WALLJUMPS_SPRINTING
		else:
			walljumps = MAX_WALLJUMPS
	
		JUMP_VELOCITY = DEFAULT_JUMP_VELOCITY
		
	# add head bump animation when hitting floor	
	
		

	# Handle sprint
	if Input.is_action_pressed("sprint"):
		isSprinting = true
		#reset crouch state
		isCrouching = false
		isSliding = false
		#prints('crouching: ', isCrouching)
	else:
		isSprinting = false
	
	if isSprinting:
		speed = RUN_SPEED
		#camera.fov = RUN_FOV
		if Input.is_action_pressed("forward"):
			# fix this bug with errors if fov gains certain point
			# fixed!!
			camera.fov = lerp(camera.fov, RUN_FOV, cameraZoom)
			camera.fov = clamp(camera.fov, WALK_FOV, RUN_FOV)
			
	# ladderzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
	# just f_ckin figure it out...
	if ladder_raycast.is_colliding():
		#prints(ladder_raycast.get_collider())
		if ladder_raycast.get_collider() == ladder:
			prints('colliding with ladder')	
			
			
			
	if isCrouching:
		speed = CROUCH_SPEED
		#prints(player_capsule.shape)
	
	#crouching / sliding
	#add lay down logic simillar to this
	#WIP ---------------------------------------------------------
	
	# pressing c should toggle the isCrouching var to true
	if isSprinting and not isCrouching and Input.is_action_just_pressed("crouch"):
		isCrouching = true
		isSliding = true
		#prints('crouching: ', isCrouching)
		prints('sliding: ', isSliding)
		
		#sliding logic (animations and trasforms on player capsule/camera)
	
	if Input.is_action_just_pressed("crouch") and not isCrouching:
		isCrouching = true
		prints('crouching: ', isCrouching)
		
		
		#crouching logic (transform player camera)

	elif Input.is_action_just_pressed("crouch") and isCrouching:
		isCrouching = false
		prints('crouching: ', isCrouching)

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
		#velocity.x = move_toward(velocity.x, 0, speed)
		if not is_on_floor():
			velocity.x = move_toward(velocity.x, 0, speed * delta * 0.5)
			velocity.z = move_toward(velocity.z, 0, speed * delta * 0.5)
		else:	
			velocity.x = move_toward(velocity.x, 0, speed * delta * 6)
			velocity.z = move_toward(velocity.z, 0, speed * delta * 6)
		
		
#animations -------------------------------
	if direction != Vector3():
		if is_on_floor():
			if isSprinting:
				anim_play.play("head_bob", -1, 1.6)
			else:
				anim_play.play("head_bob", -1, 0.8)
	
	if direction == Vector3():
			anim_play.stop()
			
	#if isSliding:
		
		#slide_anim.play("sliding_anim", -1, 1)
	#if not isCrouching:
		#slide_anim.stop()
		
	move_and_slide()
