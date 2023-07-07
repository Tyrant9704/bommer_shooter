extends Node3D

@onready var raycast_container = $raycast_container
@onready var raycast_origin = $"../../Camera3D/raycast_origin"
@onready var shotgun = $body
@onready var camera_shake = $"../../Camera3D"
@onready var ammo_count = $"../../Camera3D/Control/ammo_count"

@onready var bullet_hole = preload("res://scenes/env/bullet_hole.tscn")
@onready var shotgun_shell = preload("res://scenes/guns/shotgun_shell.tscn")

@export var pos_normal = Vector3()
var rot_normal = Vector3(0, 0, 0)
@export var pos_aim = Vector3()
@export var rot_aim = Vector3()

var shell_v = Vector3(0, 0, -5)

var spread = 10
var ammo = 150

var have_ammo = true
var next_shot = true
var effect = Vector3(-5, 0, 0)

var LERP = 20


func _ready():
	_spread()

func _process(delta):
	raycast_container.global_transform.origin = raycast_origin.global_transform.origin
	raycast_container.global_rotation = raycast_origin.global_rotation
	
	ammo_count.set_text('Ammo' + '' + var_to_str(ammo))
	if ammo >= 1:
		have_ammo
	else:
		have_ammo = false

	if Input.is_action_just_pressed("LMB"):
		if have_ammo && next_shot:
			$AnimationPlayer.play('shoot')
			$AudioStreamPlayer.play()
			var recoil_p = Vector3(7, 0, 0)
			var recoil_r = Vector3(0, 0, -1)
			shotgun.transform.origin = shotgun.transform.origin.lerp(shotgun.transform.origin + recoil_p, LERP * delta)
			shotgun.rotation = shotgun.rotation.lerp(shotgun.rotation + recoil_r, LERP * delta)
			
			var shell = shotgun_shell.instantiate()
			shell.transform.origin = $body/Marker3D.transform.origin
			$body/Marker3D.add_child(shell)
			shell.apply_central_impulse(self.global_transform.basis * shell_v)
			ammo -= 1
			
			
			_fire()
			_spread()
		
			camera_shake.add_trauma(0.5, 5)
	if Input.is_action_pressed("RMB"):
		shotgun.transform.origin =shotgun.transform.origin.lerp(pos_aim, LERP * delta)
		shotgun.rotation =shotgun.rotation.lerp(rot_aim, LERP * delta)
	else:
		shotgun.transform.origin =shotgun.transform.origin.lerp(pos_normal, LERP * delta)
		shotgun.rotation =shotgun.rotation.lerp(rot_normal, LERP * delta)
func _spread():
	for r in raycast_container.get_children():
		r.target_position.x = randf_range(spread, -spread)
		r.target_position.y = randf_range(spread, -spread)
	
func _fire():
	for r in raycast_container.get_children():
	#next_shot = false
		var collider = r.get_collider()
		if r.get_collision_mask_value(5):
			if r.is_colliding():
				
				if collider.has_method('hit'):
						collider.hit()
				
				next_shot = false
				if collider is RigidBody3D:
					collider.apply_central_impulse(self.global_transform.basis * effect)
				if collider and 'enemy' in collider.get_groups():
					collider._health(20)
				else:
					var b_hole = bullet_hole.instantiate()
					collider.add_child(b_hole)
					b_hole.global_transform.origin = r.get_collision_point()
					b_hole.look_at(r.get_collision_point() + r.get_collision_normal(), Vector3.UP)
		

func _on_animation_player_animation_finished(shoot):
	next_shot = true
