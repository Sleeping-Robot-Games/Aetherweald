class_name BaseState
extends Node

@export var animation_name: String
var animation_player: AnimationPlayer

# Pass in a reference to the actor's character body so that it can be used by the state
var actor: CharacterBody2D

func enter() -> void:
	actor.direction_string = get_dir(actor.direction)
	if 'Player' in actor.name:
		actor.play_animation(animation_name + '_' + actor.direction_string)

func exit() -> void:
	pass

func get_dir(vector: Vector2) -> String:
	var dominant_axis = 'x' if abs(vector.x) >= abs(vector.y) else 'y'
	if dominant_axis == 'x':
		return 'left' if vector.x <= 0 else 'right'
	else:
		return 'up' if vector.y <= 0 else 'down'

func input(_event: InputEvent) -> BaseState:
	return null

func process(_delta: float) -> BaseState:
	return null

func physics_process(_delta: float) -> BaseState:
	return null
