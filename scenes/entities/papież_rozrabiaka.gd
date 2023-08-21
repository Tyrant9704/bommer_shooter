extends CharacterBody3D
class_name enemy

var speed = 3.0




@onready var player = $"../Player"


var health = 100.0

@onready var nav_agent = $NavigationAgent3D


func _ready():
	$AnimationPlayer.play("Armature|mixamo_com|Layer0")
	
func _health(health_amount):
	
	health -= health_amount
	if health <= 0:
		visible = false

func _process(delta):

	if Engine.get_physics_frames() %15 == 0:
		nav_agent.target_position = player.global_transform.origin
			
	var next_point = nav_agent.get_next_path_position()
	var move_toward = (next_point - global_transform.origin).normalized() * speed
	
	velocity = velocity.move_toward(move_toward, .25)
	move_and_slide()
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)



func _on_navigation_agent_3d_target_reached():
	pass


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	pass # Replace with function body.
