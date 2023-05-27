extends Node3D

@onready var raycast = $RayCast3D
var effect = Vector3(0, -10, -10)
@onready var hole = preload("res://scenes/env/bullet_hole.tscn")

#@export var hip = Vector3(0.925, -1.642, -1.429)
#@export var hip_recoil = Vector3(0.925, -1.642, -1.315)
#@export var aim = Vector3(0.012, -1.528, -1.082)
#@export var aim_recoil = Vector3(0.012, -1.528, -0.931)
@export var hip = Vector3(0, -0.5, 0)
@export var hip_recoil = Vector3(0, -0.5, 0)
@export var aim = Vector3(0, 0, 0)
@export var aim_recoil = Vector3(0, 0, 0)
const  aim_lerp = 20
const recoil = 40
var allow_next = true


func _ready():
	$Scope

func _process(delta):
	fire()
	if Input.is_action_pressed("RMB"):
		if allow_next == true:
			transform.origin = transform.origin.lerp(aim, aim_lerp * delta)
		else:
			transform.origin = transform.origin.lerp(aim_recoil, recoil * delta)
	else:
		if allow_next == true:
			transform.origin = transform.origin.lerp(hip, aim_lerp * delta)
		else:
			transform.origin = transform.origin.lerp(hip_recoil, recoil * delta)
		
		
func fire():
	var collider = raycast.get_collider()
	var b_hole = hole.instantiate()
	if Input.is_action_pressed("LMB") and allow_next == true:
		if not $AnimationPlayer.is_playing():
			if raycast.get_collision_mask_value(5):
				if raycast.is_colliding():
					if collider is RigidBody3D:
						collider.apply_central_impulse(self.global_transform.basis * effect)
					else:
						collider.add_child(b_hole)
						b_hole.global_transform.origin = raycast.get_collision_point()
						b_hole.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)
		$AnimationPlayer.play('aim_shoot')
