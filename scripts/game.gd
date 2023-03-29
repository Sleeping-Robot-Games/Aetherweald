extends Node2D

@onready var slime_scene = preload('res://scenes/slime.tscn')
@onready var slime_spawn_positions = [
	$SlimeSpawnPos,
	$SlimeSpawnPos2,
	$SlimeSpawnPos3
]

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_slime()

func spawn_slime():
	var new_slime = slime_scene.instantiate()
	print(slime_spawn_positions.pick_random())
	new_slime.global_position = slime_spawn_positions.pick_random().global_position
	add_child(new_slime)
