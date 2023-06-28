extends Node3D


enum EAmmoType {standard, heavy, special, sniper}

@export var ammo_type: EAmmoType

@onready var standard_ammo_box = $standardAmmoBox
@onready var heavy_ammo_box = $heavyAmmoBox
@onready var special_ammo_box = $specialAmmoBox
@onready var sniper_ammo_box = $sniperAmmoBox


@export var quantity = 10

@onready var audio = $AudioStreamPlayer3D
func _ready():
	if ammo_type == EAmmoType.standard:
		standard_ammo_box.visible = true
	elif ammo_type == EAmmoType.heavy:
		heavy_ammo_box.visible = true
	elif ammo_type == EAmmoType.special:
		special_ammo_box.visible = true
	else:
		sniper_ammo_box.visible = true


func _on_area_3d_body_entered(body):
	if body.has_method('add_ammo'):
		body.add_ammo(ammo_type, quantity)
		audio.play()
		standard_ammo_box.visible = false
		heavy_ammo_box.visible = false
		special_ammo_box.visible = false
		sniper_ammo_box.visible = false



func _on_audio_stream_player_3d_finished():
		queue_free()		
