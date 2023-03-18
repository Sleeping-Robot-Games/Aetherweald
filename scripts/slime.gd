extends CharacterBody2D

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get('parameters/playback')

@export var speed: float = 300.0

# TODO
#func _physics_process(delta):
#	move_and_slide()
