extends Node3D

@export var pos_normal = Vector3()
@export var rot_normal = Vector3(0, 0, 0)

@export var pos_aim = Vector3()
@export var rot_aim = Vector3()

var LERP = 20
var recoil_lerp = 5
var have_ammo =  true
var effect = Vector3(0, -5, 10)


@onready var spear = $spear
@onready var raycast_origin = $"../../Camera3D/raycast_origin"
@onready var anim = $AnimationPlayer
@onready var bullet_origin = $RayCast
@onready var camera_shake = $"../../Camera3D"
@onready var bullet_hole = preload("res://scenes/env/bullet_hole.tscn")



func _ready():
	pass

func _process(delta):

	var recoil_p = Vector3(0, 1, 0)
	
	if Input.is_action_pressed("RMB"):
		spear.transform.origin = spear.transform.origin.lerp(pos_aim, LERP * delta)
		spear.rotation = spear.rotation.lerp(rot_aim, LERP * delta)
	else:
		spear.transform.origin = spear.transform.origin.lerp(pos_normal, LERP * delta)
		spear.rotation = spear.rotation.lerp(rot_normal, LERP * delta)

	$RayCast.global_transform.origin = raycast_origin.global_transform.origin
	$RayCast.global_rotation = raycast_origin.global_rotation
	
	
	if Input.is_action_pressed("LMB"):
		anim.play("fire")
		spear.transform.origin = spear.transform.origin.lerp(spear.transform.origin + recoil_p, recoil_lerp * delta)
	else:
		anim.stop()
		
		
func _fire():
	$AudioStreamPlayer3D.play()
	var collider = bullet_origin.get_collider()
	if have_ammo:
		camera_shake.add_trauma(0.5, 0,6)
		if bullet_origin.is_colliding():
			if collider is RigidBody3D:
				collider.apply_central_impulse(self.global_transform.basis * effect)
			if collider and 'enemy' in collider.get_groups():
				collider._health(35)
			if collider and 'target' in collider.get_groups():
				collider._target_hit()
			else:
				var b = bullet_hole.instantiate()
				collider.add_child(b)
				b.global_transform.origin = bullet_origin.get_collision_point()
				if bullet_origin.get_collision_normal() == Vector3(0,1,0):
					b.look_at(bullet_origin.get_collision_point() + bullet_origin.get_collision_normal(), Vector3.RIGHT)
				elif bullet_origin.get_collision_normal() == Vector3(0,-1,0):
					b.look_at(bullet_origin.get_collision_point() + bullet_origin.get_collision_normal(), Vector3.RIGHT)
				else:
					b.look_at(bullet_origin.get_collision_point() + bullet_origin.get_collision_normal())
