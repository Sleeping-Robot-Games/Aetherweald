extends CharacterBody2D

@export var speed: float = 300.0
var moving: bool = false
var direction: Vector2 = Vector2(0, -1)
var direction_string: String = "Up"

func _ready():
	$PlayerStateManager.init(self)

func play_animation(anim_name):
	$AnimationPlayer.play(anim_name)
