extends Node3D

@onready var raycast = $"M1911-handgun/raycast"
var effect = Vector3(0, 10, 10)
@onready var hole = preload("res://scenes/env/bullet_hole.tscn")
@export var hip = Vector3(0.578, -0.513, -0.397)
@export var hip_recoil = Vector3(0.578, -0.564, -0.322)
@export var aim = Vector3(0.036, -0.324, -0.397)
@export var aim_recoil = Vector3(0.036, -0.389, -0.239)
const  aim_lerp = 20
const recoil = 40
var allow_next = true

func _ready():
	pass 

func _process(delta):
	if Input.is_action_pressed("aim"):
		if allow_next == true:
			transform.origin = transform.origin.lerp(aim, aim_lerp * delta)
		else:
			transform.origin = transform.origin.lerp(aim_recoil, recoil * delta)
	else:
		if allow_next == true:
			transform.origin = transform.origin.lerp(hip, aim_lerp * delta)
		else:
			transform.origin = transform.origin.lerp(hip_recoil, recoil * delta)
		
		
func _input(event):
	var collider = raycast.get_collider()
	var b_hole = hole.instantiate()
	if Input.is_action_just_pressed("shoot") and allow_next == true:
		$AnimationPlayer.play('shoot_aim')
		if raycast.get_collision_mask_value(5):
			if raycast.is_colliding():
				allow_next = false
				if collider is RigidBody3D:
					collider.apply_central_impulse(self.global_transform.basis * effect * 4)
				else:
					collider.add_child(b_hole)
					b_hole.global_transform.origin = raycast.get_collision_point()
					b_hole.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)
	


func _on_animation_player_animation_finished(anim_name):
	allow_next = true
