extends CharacterBody2D

@export var speed: float = 400.0
var moving: bool = false
var direction: Vector2 = Vector2(0, -1)
var direction_string: String = "up"

func _ready():
	$PlayerStateManager.init(self)

func play_animation(anim_name):
	$AnimationPlayer.play(anim_name)

func dmg(num):
	print("player damaged")
