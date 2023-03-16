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

func get_dir(input: Vector2) -> String:
	var dominant_axis = 'x' if abs(input.x) >= abs(input.y) else 'y'
	if dominant_axis == 'x':
		return 'Left' if input.x <= 0 else 'Right'
	else:
		return 'Up' if input.y <= 0 else 'Down'

func input(_event: InputEvent) -> BaseState:
	return null

func process(_delta: float) -> BaseState:
	return null

func physics_process(_delta: float) -> BaseState:
	return null
