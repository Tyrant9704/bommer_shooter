extends CharacterBody3D




var speed = 0
var acceleration = 6
const DEFAULT_SPEED = 10.0
const RUN_SPEED = 22.0
const CROUCH_SPEED = 6.0

const RUN_FOV = 70.0
const WALK_FOV = 60.0
const ZOOM_FOV = 40.0

const sway = 10

const DEFAULT_JUMP_VELOCITY = 15.0
var JUMP_VELOCITY = 15.0

const MAX_WALLJUMPS = 2
const MAX_WALLJUMPS_SPRINTING = 5
var walljumps = 2


# is changing depending from the player state
var player_state = 'idle'
var player_pos = 'stand'

#const player_height_standing = 2
#const player_height_crouching = 0.5


const MOUSE_SENSITIVITY = 0.1

# jetpack variables
var maxJetpackEnergy = 100
var currentJetpackEnergy = 100
var jetpackRegenRate = 0.1
var jetpackThrust = 1
var canFly = true
var jetpackEnabled = false
var jetpack_hold = 0.0
const hold_time = 0.3

var timer = Timer.new()
var effect = Vector3(0, -5, -5)
var cameraZoom = 0.0

# "we need guns... lots of guns..."
var current_weapon : String
var desired_weapon : String

# temporary hardcoded!
# nie powinnismy hardcodowac broni, beda zapewne do wyboru w jakims menu (przed startem gry w lobby / whatever)
# beda pushowane do tej tablicy dynamicznie z UI lobby (guns menu or whtev)
var weapons = ['M1911_normal', 'm1911_alt', 'weapon_3', 'shotgun']



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 4 # multiplied by four xd

@onready var neck := $head
@onready var camera := $head/Camera3D
@onready var player_capsule = $Player_collision
@onready var ladder = $"../ladder"
@onready var ladder_raycast = $ladder_raycast
#ui ? ?? 
@onready var jetpackLabel = $head/Camera3D/Control/jetpack_label
@onready var ammo_count = $head/Camera3D/Control/ammo_count
@onready var joint = $"head/joint"
@onready var hand = $head/hand
# dziala to?  xd
#func update_jetpackLabel_col():
#	jetpackLabel.label_settings.font_color = currentJetpackEnergy
	
func  _ready():
	joint.top_level = true
	
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
	
	# handle weapon slots
	if Input.is_action_just_pressed('weapon_slot_1'):
		desired_weapon = weapons[0]
		_weapon_switcher()
	if Input.is_action_just_pressed("weapon_slot_2"):
		desired_weapon = weapons[1]
		_weapon_switcher()
	if Input.is_action_just_pressed("weapon_slot_3"):
		desired_weapon = weapons[2]
		_weapon_switcher()
	if Input.is_action_just_pressed("weapon_slot_4"):
		desired_weapon = weapons[3]
		_weapon_switcher()


func _weapon_switcher():
		for weapon in joint.get_children():
			if  weapon.name == desired_weapon:
				weapon.visible = true
				weapon.set_process(true)
		
			elif weapon.name == current_weapon:
				weapon.visible = false
				weapon.set_process(false)
			else:
				weapon.visible = false
				weapon.set_process(false)
		current_weapon = desired_weapon


func _process(delta):
	#anim_handler
	global_script.player_pos = player_pos
	global_script.player_state = player_state
		
	joint.global_transform.origin = hand.global_transform.origin
	joint.rotation.y = lerp_angle(joint.rotation.y, rotation.y, sway * delta)
	joint.rotation.x = lerp_angle(joint.rotation.x, neck.rotation.x, sway * delta)
		# Handle sprint & shit
	if speed == DEFAULT_SPEED:
		player_state = 'walk'
	if self.get_velocity() == Vector3.ZERO:
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
		camera.fov = ZOOM_FOV

#----jetpack & ammo-----
	jetpackLabel.set_text("jetpack: " + var_to_str(floor(currentJetpackEnergy)) + " %")
	#ammo_count.set_text('Ammo' + ' ' + var_to_str((max(0,mag)))+ '/' + var_to_str(max(0, max_ammo)))
	
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
		
	# Handle walljumps
	#decrease height of the subsequent jumps over time !!! this will improve
	# weird feeling of unlimited jumpiness XD
	
	elif Input.is_action_just_pressed("jump") and is_on_wall() and walljumps > 0:
		velocity.y = JUMP_VELOCITY
		JUMP_VELOCITY -= 2.5
		walljumps -= 1

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


	move_and_slide()

#random raycast origin, don't mind it. He was happy here
	#bullet_origin.transform.origin = $head/Camera3D.transform.origin
	

