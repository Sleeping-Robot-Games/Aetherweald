extends CharacterBody2D

@export var pat_speed: float = 200.0
@export var chase_speed: float = 50.0
@export var charge_speed: float = 150.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var target: CharacterBody2D
var facing = "Right"
var state = "idle"
var charge_target_pos: Vector2

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
		
	if state == 'charge':
		if global_position.distance_to(charge_target_pos) < 10:
			# Slime reached charge location without hitting player
			end_chase()
			
		animate_sprite(global_position, charge_target_pos)
		
		# Move to where the player was when the charge started
		var direction: Vector2 = global_position.direction_to(charge_target_pos)
		var new_velocity = direction * charge_speed

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
		if state == 'charge':
			$AnimationPlayer.play("charge_" + facing)
		else:
			$AnimationPlayer.play("walk_" + facing)

func start_chase(body):
	target = body
	state = "chase"
	$FollowTimer.start()

func start_charge(body):
	state = "charge"
	charge_target_pos = body.global_position


func end_chase():
	state = "idle"
	target = null
	$FollowTimer.stop()
	$Scan.start()


func _on_chase_area_body_entered(body):
	if body.name == "Player":
		start_chase(body)


func _on_chase_area_body_exited(body):
	if target == body:
		end_chase()


func _on_follow_timer_timeout():
	if target:
		navigation_agent.target_position = target.global_position


func _on_charge_area_body_entered(body):
	if body == target:
		start_charge(body)

func _on_hit_area_body_entered(body):
	if body == target and not target.rolling:
		body.dmg(1)
		end_chase()

func _on_scan_timeout():
	var chase_bodies = $ChaseArea.get_overlapping_bodies()
	var charge_bodies = $ChargeArea.get_overlapping_bodies()
	
	for body in charge_bodies:
		if body.name == "Player":
			return start_charge(body)

	for body in chase_bodies:
		if body.name == "Player":
			return start_chase(body)
	
