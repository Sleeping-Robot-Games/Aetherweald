extends CharacterBody2D

@export var pat_speed: float = 200.0
@export var chase_speed: float = 50.0
@export var charge_speed: float = 150.0
@export var charge_distance: float = 300.0
@export var max_hp: int = 10

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var hp: int
var target: CharacterBody2D
var facing = 'right'
var state = 'idle'
var charge_target_pos: Vector2
var hurt_dir: Vector2
var hurt_knockback: float
var prev_position: Vector2

const YELLOW = Color(1.0, 1.0, 0.0, 1.0)
const RED = Color(1.0, 0.0, 0.0, 1.0)

func _ready():
	## TODO: Actually kill off slime and when they die spawn another
	
	$AnimationPlayer.play('idle_down')
	prev_position = global_position
	hp = max_hp
	$HpBar.max_value = max_hp
	$HpBar.value = max_hp
	# make shader unique
	$Sprite.material = $Sprite.material.duplicate()

func _physics_process(delta):
	## TODO: See notes in dmg()
	if state == 'idle':
		$AnimationPlayer.play('idle_down')
	
	if state == 'hurt':
		animate_sprite(prev_position, global_position)
		velocity = velocity.move_toward(Vector2.ZERO, hurt_knockback * delta)
		move_and_slide()

	if state == 'chase':
		var current_agent_position: Vector2 = global_transform.origin
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()

		animate_sprite(current_agent_position, next_path_position)
		
		velocity = (next_path_position - current_agent_position).normalized()
		velocity *= chase_speed
		move_and_slide()
		
	if state == 'charge_windup':
		if $Exclamation.visible:
			$AnimationPlayer.play('idle_down')
		else:
			$Sprite.material.set_shader_parameter('enabled', true)
			$Sprite.material.set_shader_parameter('tint', YELLOW)
			$AnimationPlayer.play('charge_windup_' + facing)
	
	if state == 'charge':
		var target_dir = (charge_target_pos - global_position).normalized()
		var velocity_dir = velocity.normalized()
		
		# end charge if close enough to target or if overshot target
		if velocity.distance_to(charge_target_pos) < 10 or \
		target_dir.dot(velocity_dir) < 0:
			end_chase()
		
		# otherwise keep charging
		animate_sprite(prev_position, global_position)
		velocity = target_dir * charge_speed
		move_and_slide()
	
	prev_position = global_position


func animate_sprite(from, to):
	# Determine which way to face enemy based on prior position
	var dir = from.direction_to(to)
	var dominant_axis = 'x' if abs(dir.x) > abs(dir.y) else 'y'
	var new_facing = facing
	if dominant_axis == 'x':
		new_facing = 'right' if dir.x > 0 else 'left'
	else:
		new_facing = 'down' if dir.y > 0 else 'up'
		
	# Animate enemy in appropriate direction
	if facing != new_facing:
		facing = new_facing
		if state == 'charge':
			$AnimationPlayer.play('charge_' + facing)
		elif state == 'hurt':
			$AnimationPlayer.play('hurt_' + facing)
		else:
			$AnimationPlayer.play('walk_' + facing)

func start_chase(body):
	target = body
	state = 'chase'
	$FollowTimer.start()

func charge_windup(body):
	state = 'charge_windup'
	var charge_dir = global_position.direction_to(body.global_position)
	charge_target_pos = global_position + charge_dir * charge_distance
	# show exclamation briefly before actual windup begins
	$Exclamation.visible = true
	$ExclamationTimer.start()
	# charge windup timer's duration accounts for pre-windup exclamation time
	$ChargeWindupTimer.start()

func start_charge():
	state = 'charge'
	$Sprite.material.set_shader_parameter('tint', RED)

func end_chase():
	$Sprite.material.set_shader_parameter('enabled', false)
	state = 'idle'
	target = null
	$FollowTimer.stop()
	$Scan.start()

func dmg(num: int, dir: Vector2 = Vector2.ZERO, force: float = 0.0) -> void:
	## TODO: Make sure hurt animation is prioritized and no animations play until hurt is done
	## TODO: Make sure the enemy can be dmg'd right away again
	print('slime damaged: ' + str(num) + ', dir: ' + str(dir) + ', force: ' + str(force))
	hp = maxi(0, hp - num)
	$HpBar.value = hp
	state = 'hurt'
	target = null
	hurt_dir = dir
	hurt_knockback = force
	velocity = hurt_dir * hurt_knockback
	$FollowTimer.stop()
	$Scan.stop()
	$HurtTimer.start()
	$AnimationPlayer.play('hurt_' + facing)

func _on_chase_area_body_entered(body):
	if body.name == 'Player':
		start_chase(body)

func _on_chase_area_body_exited(body):
	if target == body:
		end_chase()

func _on_follow_timer_timeout():
	if target:
		navigation_agent.target_position = target.global_position

func _on_charge_area_body_entered(body):
	if body == target and not 'charge' in state:
		charge_windup(body)

func _on_hit_area_body_entered(body):
	if state == 'charge' and body == target and not target.is_invulnerable and not \
	'roll' in target.get_node('AnimationPlayer').current_animation:
		body.dmg(1)

func _on_scan_timeout():
	var chase_bodies = $ChaseArea.get_overlapping_bodies()
	var charge_bodies = $ChargeArea.get_overlapping_bodies()
	
	for body in charge_bodies:
		if body.name == 'Player' and not 'charge' in state:
			return charge_windup(body)

	for body in chase_bodies:
		if body.name == 'Player':
			return start_chase(body)

func _on_hurt_timer_timeout():
	end_chase()

func _on_charge_windup_timer_timeout():
	start_charge()

func _on_exclamation_timer_timeout():
	$Exclamation.visible = false
