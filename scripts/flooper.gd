extends StaticBody2D

@onready var level = get_parent()
@onready var bullet_scene = preload("res://scenes/enemies/flooper_bullet.tscn")

var spawn: Vector2i
var waiting: bool = false
var current_target_pos: Vector2
var dead: bool = false
var hp: int = 3

func _ready():
	$AnimationPlayer.play('idle')

func _process(delta):
	pass

func _on_aggro_range_body_entered(body):
	if body.name == 'Player' and not waiting:
		start_attack(body.global_position)

func start_attack(target_pos):
	current_target_pos = target_pos
	$AnimationPlayer.play('attack')
	waiting = true
	$AttackTimer.start()
	
func attack():
	$WaitTimer.start()
	var new_bullet = bullet_scene.instantiate()
	new_bullet.global_position = $Marker2D.global_position
	new_bullet.target_pos = current_target_pos
	get_parent().add_child(new_bullet)

func _on_wait_timer_timeout():
	if dead:
		return
		
	waiting = false
	var aggro_bodies = $AggroRange.get_overlapping_bodies()
	for body in aggro_bodies:
		if body.name == 'Player':
			start_attack(body.global_position)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'attack':
		$AnimationPlayer.play('idle')
	if anim_name == 'hurt':
		$WaitTimer.start()
		$AnimationPlayer.play('idle')
	if anim_name == 'death':
		queue_free()

func _on_attack_timer_timeout():
	attack()

func dmg(num: int, dir: Vector2 = Vector2.ZERO, force: float = 0.0) -> void:
	if dead:
		return
		
	hp = maxi(0, hp - num)
	# $HpBar.value = hp
	if hp == 0:
		dead = true
		$AnimationPlayer.play('death')
		if level.has_method('enemy_died'):
			level.enemy_died(spawn)
		return
		
	waiting = true
	$AnimationPlayer.play('hurt')
