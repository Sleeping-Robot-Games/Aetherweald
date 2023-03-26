extends CharacterBody2D

@export var speed: float = 400.0
var hp: int = 10
var moving: bool = false
var direction: Vector2 = Vector2(0, -1)
var direction_string: String = 'up'
var rolling = false # This is really more for pseudo code right now

func _ready():
	$PlayerStateManager.init(self)

func play_animation(anim_name):
	$AnimationPlayer.play(anim_name)

func dmg(num):
	print('player damaged')
	hp = maxi(0, hp - num)
	$HpBar.value = hp

func _on_attack_area_body_entered(body):
	if body.has_method('dmg'):
		var anim: String = $AnimationPlayer.current_animation
		var damage: int = 1 if 'light' in anim else 3
		var force: float = 0.0
		if 'light3' in anim:
			force = 300.0
		elif 'heavy' in anim:
			force = 400.0
		var dir: Vector2 = global_position.direction_to(body.global_position).normalized()
		body.dmg(damage, dir, force)
