extends RigidBody3D


const GRENADE_DAMAGE = 20

const GRENADE_TIME = 2
var grenade_timer = 0

const EXPLOSION_WAIT_TIME = 4.0
var explosion_wait_timer = 0

#duration of discharge (emitting)
const DURATION = 4.0

const MAX_LIGHT_ENERGY = 30
const MAX_RANGE = 8

@onready var rigid_shape = $CollisionShape3D
@onready var grenade_mesh = $MeshInstance3D
@onready var blast_area = $Area3D
@onready var explosion_particles = $explosion_particles
@onready var emission_particles = $emission_particles
@onready var explosion_sfx = $AudioStreamPlayer3D
@onready var explosion_light = $OmniLight3D
@onready var distortion = $DistortionShader

func _ready():
	pass


func _process(delta):
	if grenade_timer < GRENADE_TIME:
		grenade_timer += delta
		return
	else:
		if explosion_wait_timer <= 0:
			explosion_particles.emitting = true
			emission_particles.emitting = true
			distortion.visible = true
			
			explosion_light.light_indirect_energy = 10.0
			
			explosion_sfx.play()
					
		if explosion_wait_timer < EXPLOSION_WAIT_TIME:
			explosion_wait_timer += delta
			
			var bodies = blast_area.get_overlapping_bodies()
			for body in bodies:
				if body.is_in_group('enemy'):
					body._health(delta * GRENADE_DAMAGE)
			# 
			if explosion_light.light_energy < MAX_LIGHT_ENERGY:
				explosion_light.light_energy += delta * 20
				
			if explosion_light.omni_range < MAX_RANGE:
				explosion_light.omni_range += delta * 20
			
			if explosion_wait_timer >= EXPLOSION_WAIT_TIME:
				queue_free()
