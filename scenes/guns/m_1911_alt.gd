extends Node3D

var LERP = 10

@export var r_hand_pos = Vector3()
@export var r_hand_rot = Vector3()
@export var r_hand_pos_n = Vector3()
@export var r_hand_rot_n = Vector3()


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
		var recoil_z = Vector3(0, 0, randi_range(1, 1.1))
		var recoil_r = Vector3(randi_range(1, 3), 0, 0)
		var left_gun = true
		var right_gun = false
		if left_gun:
			$l_hand.transform.origin = $l_hand.transform.origin.lerp(l_hand_pos - recoil_z, LERP * delta)
			$l_hand.rotation = $l_hand.rotation.lerp(l_hand_rot - recoil_r, LERP * delta)
		$"r-hand".transform.origin = $"r-hand".transform.origin.lerp(r_hand_pos - recoil_z, LERP * delta)
		$"r-hand".rotation = $"r-hand".rotation.lerp(r_hand_rot - recoil_r, LERP * delta)

