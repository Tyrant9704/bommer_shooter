extends RigidBody3D


const GRENADE_DAMAGE = 100

const GRENADE_TIME = 2
var grenade_timer = 0

const EXPLOSION_WAIT_TIME = 0.4
var explosion_wait_timer = 0

@onready var rigid_shape = $CollisionShape3D
@onready var grenade_mesh = $MeshInstance3D
@onready var blast_area = $Area3D
@onready var explosion_particles = $GPUParticles3D
@onready var explosion_sfx = $AudioStreamPlayer3D
@onready var explosion_light = $OmniLight3D

func _ready():
	pass


func _process(delta):
	if grenade_timer < GRENADE_TIME:
		grenade_timer += delta
		return
	else:
		if explosion_wait_timer <= 0:
			explosion_particles.emitting = true
			
			explosion_light.light_energy = 10.0
			explosion_light.light_indirect_energy = 10.0
			
			grenade_mesh.visible = false
			rigid_shape.disabled = true
			
			explosion_sfx.play()
			var bodies = blast_area.get_overlapping_bodies()
			for body in bodies:
				if body.is_in_group('enemy'):
					body.apply_central_impulse(Vector3(10, 10, 10))
					body.health -= GRENADE_DAMAGE
					
		
		if explosion_wait_timer < EXPLOSION_WAIT_TIME:
			explosion_wait_timer += delta
			
			if explosion_wait_timer >= EXPLOSION_WAIT_TIME:
				queue_free()
