extends Node3D

var LERP = 10

var switch = false
var have_ammo = true
var current_ammo = 150
var can_shoot = true

#aim mode
@export var r_hand_pos = Vector3()
@export var r_hand_rot = Vector3()

#neutral mode
@export var r_hand_pos_n = Vector3()
@export var r_hand_rot_n = Vector3()

@onready var camera_shake = $"../../Camera3D"
@onready var camera = $"../../Camera3D/raycast_origin"
@onready var ammo_count = $"../../Camera3D/Control/ammo_count"
@onready var bullet_origin = $bullet_origin

var effect = Vector3(0, -5, 10)
var case_v = Vector3(randf_range(-2.8, -3.2), 2, 0)
var case_r = Vector3(randf_range(1,2), randf_range(5,7), randf_range(5,6))

@onready var bullet_hole = preload("res://scenes/env/bullet_hole.tscn")
@onready var shell = preload("res://scenes/guns/shell.tscn")

@onready var l_shell = $l_hand/M1911/l_shell
@onready var r_shell = $"r-hand/M1911/r_shell"


func _ready():
	randomize()

func _process(delta):
	
	
	bullet_origin.global_transform.origin = camera.global_transform.origin
	bullet_origin.global_rotation = camera.global_rotation
	
	ammo_count.set_text('Ammo' + '' + var_to_str(current_ammo))
	if current_ammo >= 1:
		have_ammo
	else:
		have_ammo = false
	
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
		if can_shoot:
			var recoil_z = Vector3(0, 0, randi_range(1, 1.1))
			var recoil_r = Vector3(randi_range(1, 1.5), 0, 0)
			switch = !switch
			if have_ammo :
				$AudioStreamPlayer.play()
				if switch:
					$l_hand.transform.origin = $l_hand.transform.origin.lerp(l_hand_pos - recoil_z, LERP * delta)
					$l_hand.rotation = $l_hand.rotation.lerp(l_hand_rot - recoil_r, LERP * delta)
					$AnimationPlayer.play("l_fire")
					_fire()
					var case = shell.instantiate()
					case.transform.origin = l_shell.transform.origin
					get_tree().get_root().add_child(case)
					case.global_transform.origin = l_shell.global_transform.origin
					case.apply_central_impulse(self.global_transform.basis * case_v)
					case.apply_torque_impulse(case_r)
					current_ammo -= 1
					$l_hand/M1911/flash.restart()
					can_shoot = false
				else:
					$"r-hand".transform.origin = $"r-hand".transform.origin.lerp(r_hand_pos - recoil_z, LERP * delta)
					$"r-hand".rotation = $"r-hand".rotation.lerp(r_hand_rot - recoil_r, LERP * delta)
					$AnimationPlayer.play("r_fire")
					_fire()
					var case = shell.instantiate()
					get_tree().get_root().add_child(case)
					case.global_transform.origin = r_shell.global_transform.origin
					case.apply_central_impulse(self.global_transform.basis * case_v)
					case.apply_torque_impulse(case_r)
					current_ammo -= 1
					$"r-hand/M1911/flash".restart()
					can_shoot = false
			else:
				pass
				

func _fire():
	var collider = bullet_origin.get_collider()
	if have_ammo:
		camera_shake.add_trauma(0.5, 5)
		if bullet_origin.is_colliding():
			if collider is RigidBody3D:
				collider.apply_central_impulse(self.global_transform.basis * effect)
			if collider and 'enemy' in collider.get_groups():
				collider._health(20)
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


func _on_animation_player_animation_finished(fire):
	can_shoot = true

