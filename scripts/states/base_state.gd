class_name BaseState
extends Node

@export var animation_name: String

# Pass in a reference to the actor's character body so that it can be used by the state
var actor: CharacterBody2D

func enter() -> void:
	print("entering: " + animation_name)
	actor.direction_string = get_dir(actor.direction)
	if 'Player' in actor.name:
		actor.play_animation(animation_name + actor.direction_string)

func exit() -> void:
	pass

func get_dir(vec2: Vector2) -> String:
	print("get_dir: " + str(vec2))
	if vec2.y < 0:
		print("Up")
		return 'Up'
	elif vec2.y > 0:
		print("Down")
		return 'Down'
	elif vec2.x < 0:
		print("Left")
		return 'Left'
	else:
		print("Right")
		return 'Right'

func input(_event: InputEvent) -> BaseState:
	return null

func process(_delta: float) -> BaseState:
	return null

func physics_process(_delta: float) -> BaseState:
	return null
