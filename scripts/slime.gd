extends CharacterBody2D

@export var pat_speed: float = 200.0
@export var chase_speed: float = 50.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var target: CharacterBody2D
var facing = "Right"
var state = "idle"

func _ready():
	$AnimationPlayer.play("idle_down")


func _physics_process(delta):
	if state == 'idle':
		$AnimationPlayer.play('idle_down')

	if state == 'chase':
		var current_agent_position: Vector2 = global_transform.origin
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()

		animate_sprite(current_agent_position, next_path_position)
		
		var new_velocity: Vector2 = next_path_position - current_agent_position
		new_velocity = new_velocity.normalized()
		new_velocity = new_velocity * chase_speed

		set_velocity(new_velocity)

		move_and_slide()
	
func animate_sprite(from, to):
	# Determine which way to face enemy based on prior position
	var dir = from.direction_to(to)
	var dominant_axis = "x" if abs(dir.x) > abs(dir.y) else "y"
	var new_facing = facing
	if dominant_axis == "x":
		new_facing = "right" if dir.x > 0 else "left"
	else:
		new_facing = "down" if dir.y > 0 else "up"
		
	# Animate enemy in appropriate direction
	if facing != new_facing:
		facing = new_facing
		$AnimationPlayer.play("walk_" + facing)

	
func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target


func _on_chase_area_body_entered(body):
	if body.name == "Player":
		target = body
		state = "chase"
		set_movement_target(target.global_position)
		$FollowTimer.start()


func _on_chase_area_body_exited(body):
	if body.name == "Player":
		state = "idle"
		target = null
		$FollowTimer.stop()


func _on_follow_timer_timeout():
	if target:
		set_movement_target(target.global_position)


func _on_charge_area_body_entered(body):
	pass # Replace with function body.


func _on_charge_area_body_exited(body):
	pass # Replace with function body.


