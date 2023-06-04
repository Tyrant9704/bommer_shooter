extends Node3D

var LERP = 10

var switch = false
var next_shot = true

@export var r_hand_pos = Vector3()
@export var r_hand_rot = Vector3()
@export var r_hand_pos_n = Vector3()
@export var r_hand_rot_n = Vector3()

@onready var bullet_origin = $"../../Camera3D/bullet_origin"
var effect = Vector3(0, -5, 10)
@onready var bullet_hole = preload("res://scenes/env/bullet_hole.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

func _process(delta):
	
	var l_hand_rot = Vector3(r_hand_rot.x, r_hand_rot.y, -r_hand_rot.z)
	var l_hand_pos = Vector3(-r_hand_pos.x, r_hand_pos.y, r_hand_pos.z)
	var l_hand_rot_n = Vector3(r_hand_rot_n.x, r_hand_rot_n.y, -r_hand_rot_n.z)
	var l_hand_pos_n = Vector3(-r_hand_pos_n.x, r_hand_pos_n.y, r_hand_pos_n.z)

	if Input.is_action_pressed('RMB'):
		$"r-hand".transform.origin = $"r-hand".transform.origin.lerp(r_hand_pos, LERP * delta)
		$l_hand.transform.origin = $l_hand.transform.origin.lerp(l_hand_pos, LERP * delta)
		$"r-hand".rotation = $"r-hand".rotation.lerp(r_hand_rot, LERP * delta)
		$l_hand.rotation = $l_hand.rotation.lerp(l_hand_rot, LERP * delta)
	else:
		$"r-hand".transform.origin = $"r-hand".transform.origin.lerp(r_hand_pos_n, LERP * delta)
		$l_hand.transform.origin = $l_hand.transform.origin.lerp(l_hand_pos_n, LERP * delta)
		$"r-hand".rotation = $"r-hand".rotation.lerp(r_hand_rot_n, LERP * delta)
		$l_hand.rotation = $l_hand.rotation.lerp(l_hand_rot_n, LERP * delta)

	if Input.is_action_just_pressed("LMB"):
		$AudioStreamPlayer.play()
		var recoil_z = Vector3(0, 0, randi_range(1, 1.1))
		var recoil_r = Vector3(randi_range(1, 1.5), 0, 0)
		switch = !switch
		if switch:
			$l_hand.transform.origin = $l_hand.transform.origin.lerp(l_hand_pos - recoil_z, LERP * delta)
			$l_hand.rotation = $l_hand.rotation.lerp(l_hand_rot - recoil_r, LERP * delta)
			$AnimationPlayer.play("l_fire")
			_fire()
		else:
			$"r-hand".transform.origin = $"r-hand".transform.origin.lerp(r_hand_pos - recoil_z, LERP * delta)
			$"r-hand".rotation = $"r-hand".rotation.lerp(r_hand_rot - recoil_r, LERP * delta)
			$AnimationPlayer.play("r_fire")
			_fire()

func _fire():
	var collider = bullet_origin.get_collider()
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


func _on_animation_player_animation_finished(anim_name):
	next_shot = true
