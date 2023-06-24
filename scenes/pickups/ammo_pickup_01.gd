extends Node3D


enum EAmmoType {standard, heavy, special, sniper}

@export var ammo_type: EAmmoType

@export var quantity = 10

@onready var audio = $AudioStreamPlayer3D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	if body.has_method('add_ammo'):
#		prints('ammo added: '+ ammo_type + ' ' + quantity)
		body.add_ammo(ammo_type, quantity)
#		prints('ammo collected')
		prints(ammo_type, quantity)
		audio.play()
		queue_free()
#queue free deletes audiosteramplayer, how to override this?
