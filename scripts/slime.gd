extends CharacterBody2D

@export var pat_speed: float = 20.0
@export var chase_speed: float = 50.0
@export var charge_speed: float = 150.0
@export var charge_distance: float = 200.0
@export var max_hp: int = 10
@export var min_charge_distance: float = 50.0


@export var yellow_windup = false
@export var windup_timeout = 0.75

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var hp: int
var target: CharacterBody2D
var facing = 'right'
var state = 'idle'
var charge_target_pos: Vector2
var current_patrol_pos: Vector2
var hurt_dir: Vector2
var hurt_knockback: float
var prev_position: Vector2
var initial_charge_pos: Vector2

const YELLOW = Color(1.0, 1.0, 0.0, 1.0)
const RED = Color(1.0, 0.0, 0.0, 1.0)

func _ready():
	start_patrol()
	
	prev_position = global_position
	hp = max_hp
	$HpBar.max_value = max_hp
	$HpBar.value = max_hp
	# make shader unique
	$Sprite.material = $Sprite.material.duplicate()

func _physics_process(delta):
	if state == 'dead':
		return
		
	if state == 'idle':
		if $AnimationPlayer.current_animation != 'idle_'+facing:
			$AnimationPlayer.play('idle_'+facing)
	
	if state == 'patrol':
		var current_agent_position: Vector2 = global_transform.origin

		animate_sprite(current_agent_position, current_patrol_pos)
		
		velocity = (current_patrol_pos - current_agent_position).normalized()
		velocity *= pat_speed
		move_and_slide()
	
	if state == 'hurt':
		velocity = velocity.move_toward(Vector2.ZERO, hurt_knockback * delta)
		move_and_slide()

	if state == 'chase':
		var current_agent_position: Vector2 = global_transform.origin
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()

		animate_sprite(current_agent_position, navigation_agent.target_position)
		
		velocity = (next_path_position - current_agent_position).normalized()
		velocity *= chase_speed
		move_and_slide()
		
	if state == 'charge_windup':
		if yellow_windup:
			$Sprite.material.set_shader_parameter('enabled', true)
			$Sprite.material.set_shader_parameter('tint', YELLOW)
			$AnimationPlayer.play('charge_windup_' + facing)
	
	if state == 'charge':
		var target_dir = (charge_target_pos - global_position).normalized()
		var velocity_dir = velocity.normalized()
		
		# Check if the enemy has traveled at least the minimum charge distance
		var charge_distance_traveled = initial_charge_pos.distance_to(global_position)
		
		# end charge if close enough to target or if overshot target, and if the minimum charge distance has been met
		if charge_distance_traveled >= min_charge_distance and (global_position.distance_to(charge_target_pos) < 10 or target_dir.dot(velocity_dir) < 0):
			end_chase()

		# otherwise keep charging
		animate_sprite(prev_position, charge_target_pos)
		velocity = target_dir * charge_speed
		move_and_slide()

	prev_position = global_position

func get_random_position():
	randomize()
	var viewport_rect = get_viewport_rect()
	var x = randf_range(viewport_rect.position.x, viewport_rect.position.x + viewport_rect.size.x)
	var y = randf_range(viewport_rect.position.y, viewport_rect.position.y + viewport_rect.size.y)
	return Vector2(x, y)

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
	elif state in ['patrol', 'chase']:
		$AnimationPlayer.play('walk_' + facing)

func start_patrol():
	$AnimationPlayer.play("walk_" + facing)
	state = 'patrol'
	current_patrol_pos = get_random_position()
	$PatrolTimer.start()
	
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
	$ExclamationTimer.start(windup_timeout)
	# charge windup timer's duration accounts for pre-windup exclamation time
	$ChargeWindupTimer.start(windup_timeout)

func start_charge():
	print("STARTING CHARGE")
	state = 'charge'
	initial_charge_pos = global_position
	for body in $HitArea.get_overlapping_bodies():
		slime_dmg_player_check(body)
	$Sprite.material.set_shader_parameter('enabled', true)
	$Sprite.material.set_shader_parameter('tint', RED)

func end_chase():
	$Sprite.material.set_shader_parameter('enabled', false)
	state = 'patrol'
	target = null
	$FollowTimer.stop()
	$Scan.start()

func dmg(num: int, dir: Vector2 = Vector2.ZERO, force: float = 0.0) -> void:
	if state == 'dead':
		return
		
	print('slime damaged: ' + str(num) + ', dir: ' + str(dir) + ', force: ' + str(force))

	hp = maxi(0, hp - num)
	$HpBar.value = hp
	if hp == 0:
		state = 'dead'
		$AnimationPlayer.play('death_' + facing)
		return
		
	state = 'hurt'
	target = null
	hurt_dir = dir
	hurt_knockback = force
	velocity = hurt_dir * hurt_knockback
	$FollowTimer.stop()
	$Scan.stop()
	$HurtTimer.start()
	$AnimationPlayer.play('hurt_down')

func _on_chase_area_body_entered(body):
	if body.name == 'Player' and state in ['patrol', 'idle']:
		start_chase(body)

func _on_chase_area_body_exited(body):
	if target == body and 'chase' in state:
		end_chase()

func _on_follow_timer_timeout():
	if target:
		navigation_agent.target_position = target.global_position

func _on_charge_area_body_entered(body):
	if body == target and not 'charge' in state and state != 'dead':
		charge_windup(body)

func _on_hit_area_body_entered(body):
	slime_dmg_player_check(body)

func slime_dmg_player_check(body):
	if state == 'charge' and body.name == 'Player' and not body.is_invulnerable and not \
	'roll' in body.get_node('AnimationPlayer').current_animation:
		body.dmg(1)

func _on_scan_timeout():
	if state in ['dead', 'charge']:
		return
		
	var chase_bodies = $ChaseArea.get_overlapping_bodies()
	var charge_bodies = $ChargeArea.get_overlapping_bodies()
	
	for body in charge_bodies:
		if body.name == 'Player' and not 'charge' in state:
			return charge_windup(body)

	for body in chase_bodies:
		if body.name == 'Player':
			return start_chase(body)

func _on_hurt_timer_timeout():
	if state != 'dead':
		end_chase()

func _on_charge_windup_timer_timeout():
	if state == 'charge_windup': # state != 'hurt' or state != 'dead':
		start_charge()

func _on_exclamation_timer_timeout():
	$Exclamation.visible = false

func _on_animation_player_animation_finished(anim_name):
	if 'death' in anim_name:
		get_parent().spawn_slime()
		queue_free()

func _on_patrol_timer_timeout():
	if state == 'hurt' or state == 'dead':
		return
	# Slime pauses here for a second then patrols again
	state = 'idle'
	await get_tree().create_timer(1).timeout
	# if the state is still after the timeout, then patrol again
	if state == 'idle':
		start_patrol()
