extends CharacterBody3D

class_name  player


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
var Menu_mode = true

# jetpack variables
var maxJetpackEnergy = 100
var currentJetpackEnergy = 100
var jetpackRegenRate = 0.1
var jetpackThrust = 1
var canFly = true
var jetpackEnabled = false
var jetpack_hold = 0.0
const hold_time = 0.3

# landing variable (for checking if player just landed)
var landing : bool
# used for counting falling velocity for landing trauma
var fallVelocity := 0.0
# used for minimum jump trauma (camera shake)
var minFallVelocity := 0.4


# AMMO VARIABLES ********************
var player_standard_ammo = 100
var player_heavy_ammo = 100
var player_special_ammo = 100
var player_sniper_ammo = 100

var timer = Timer.new()
var effect = Vector3(0, -5, -5)
var cameraZoom = 0.0

# "we need guns... lots of guns..."
var current_weapon : String
var desired_weapon : String

# temporary hardcoded!
# nie powinnismy hardcodowac broni, beda zapewne do wyboru w jakims menu (przed startem gry w lobby / whatever)
# beda pushowane do tej tablicy dynamicznie z UI lobby (guns menu or whtev)
var weapons = ['null', 'm1911_alt', 'spear', 'shotgun']



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

@onready var grenade_point = $head/Camera3D/Grenade_Point

@onready var landing_sound = $landing_sound


# dziala to?  xd
#func update_jetpackLabel_col():
#	jetpackLabel.label_settings.font_color = currentJetpackEnergy

var grenade_scene = preload('res://scenes/guns/grenade_01.tscn')
var grenade_scene_02 = preload("res://scenes/guns/grenade_02.tscn")
var GRENADE_THROW_FORCE = 15
var GRENADE_MAX_THROW_FORCE = 60
#temp grenade quantity, TBC
var grenades = 100

var grenadesArr = ['grenade_01', 'grenade_02']

# temp array for switching current grenade
var current_grenade = grenadesArr[1]
#var can_throw_grenade = true
	
func  _ready():
	joint.top_level = true
	
func _input(event):
	
#----mouse_input-----
		
	if Input.is_action_just_pressed("ui_cancel"): #esc key
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Menu_mode = false
			prints(Menu_mode)
			# enable ingame HUD
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Menu_mode = true
			prints(Menu_mode)
			# disable ingame HUD
			# add menu screen UI
		
	#handle first person rotations
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x) * MOUSE_SENSITIVITY)
			neck.rotate_x(deg_to_rad(-event.relative.y) * MOUSE_SENSITIVITY)
			neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	# handle weapon slots
	if !Menu_mode:
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
		
	# BASIC GRENADE TOSS
	# when using middle mouse button, there is a bug - we throw multiple grenades
	# it happens because of multiple event firing
	# changed grenade throw button to G for now...
	# holding G for longer time adds delta time to GRENADE_THROW_FORCE in process function
	if !Menu_mode:
		if Input.is_action_just_released("alt_grenade"):
			
			if grenades > 0:
				grenades -=1
				prints(grenades)
				
				var grenade_clone
				
				if current_grenade == grenadesArr[0]:
					grenade_clone = grenade_scene.instantiate()
				elif current_grenade == grenadesArr[1]:
					grenade_clone = grenade_scene_02.instantiate()
				
					grenade_clone.global_transform = grenade_point.global_transform
				get_tree().root.add_child(grenade_clone)
				grenade_clone.apply_central_impulse(-grenade_clone.global_transform.basis.z * (speed / 10) * GRENADE_THROW_FORCE)
				
			#reset to minimum throw force
			GRENADE_THROW_FORCE = 15
		
	

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
	
	# grenade power timer
	if Input.is_action_pressed("alt_grenade"):
		if GRENADE_THROW_FORCE < GRENADE_MAX_THROW_FORCE:
			GRENADE_THROW_FORCE += delta * 16
	
		
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

# -------------- landing (camera shake / sfx) -----------------
	fallVelocity += -velocity.y * delta
	if is_on_floor():
		if landing:
			if(camera.has_method('add_trauma')):
				prints(fallVelocity)
#				camera.add_trauma(0.5)
				camera.add_trauma(fallVelocity, 2, true)
				
				landing_sound.pitch_scale = randf_range(0.8, 1.4)
				landing_sound.play()
				
			landing = false
			fallVelocity = minFallVelocity
	else:
		if !landing:
			landing = true

	move_and_slide()

#random raycast origin, don't mind it. He was happy here
	#bullet_origin.transform.origin = $head/Camera3D.transform.origin
	

enum EAmmoType {standard, heavy, special, sniper}
# i guess we should not have two same enums here and in ammo_pickup_01??
func add_ammo(ammo_type: EAmmoType, quantity):
#something wrong with match statement, does not work properly ??
#	match typeof(ammo_type):
#		EAmmoType.standard:
#			player_standard_ammo += quantity
#			prints('standard ammo added')
#		EAmmoType.heavy:
#			player_heavy_ammo += quantity
#			prints('heavy ammo added')
#
#		EAmmoType.special:
#			player_special_ammo += quantity
#			prints('special ammo added')
#
#		EAmmoType.sniper:
#			player_sniper_ammo += quantity
#			prints('sniper ammo added')
#		_:
#			prints('default value')
	if ammo_type == EAmmoType.standard:
		player_standard_ammo += quantity
		prints('standard ammo added')
	elif ammo_type == EAmmoType.heavy:
		player_heavy_ammo += quantity
		prints('heavy ammo added')
	elif ammo_type == EAmmoType.special:
		player_special_ammo += quantity
		prints('special ammo added')
	elif ammo_type == EAmmoType.sniper:
		player_sniper_ammo += quantity
		prints('sniper ammo added')
		
	
			
