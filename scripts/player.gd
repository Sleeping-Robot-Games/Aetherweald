extends CharacterBody2D

@onready var hit_state: BaseState = $PlayerStateManager.get_node('Hit')

@export var speed: float = 400.0
@export var light_knockback_force: float = 200.0
@export var heavy_knockback_force: float = 300.0

var hp: int = 10
var moving: bool = false
var direction: Vector2 = Vector2(0, -1)
var direction_string: String = 'up'
var is_invulnerable = false

# TODO move to global script?
var stone = 0
var gold = 0
var wood = 0

func _ready():
	$PlayerStateManager.init(self)

func play_animation(anim_name):
	$AnimationPlayer.play(anim_name)

func get_loot(type: String, amount: int = 1):
	# TODO update HUD
	if type == 'stone':
		stone += amount
	elif type == 'gold':
		gold += amount
	elif type == 'wood':
		wood += amount

func dmg(num):
	print('player damaged')
	hp = maxi(0, hp - num)
	$HpBar.value = hp
	invulnerability_window()
	$PlayerStateManager.change_state(hit_state)

func invulnerability_window():
	is_invulnerable = true
	$SpriteHolder.modulate.a = 0.5
	$HitTimer.start()

func _on_hit_timer_timeout():
	is_invulnerable = false
	$SpriteHolder.modulate.a = 1.0

func _on_attack_area_body_entered(body):
	if body.has_method('dmg'):
		var anim: String = $AnimationPlayer.current_animation
		var damage: int = 1 if 'light' in anim else 3
		var force: float = 0.0
		if 'light3' in anim:
			force = light_knockback_force
		elif 'heavy' in anim:
			force = heavy_knockback_force
		var dir: Vector2 = global_position.direction_to(body.global_position).normalized()
		body.dmg(damage, dir, force)
