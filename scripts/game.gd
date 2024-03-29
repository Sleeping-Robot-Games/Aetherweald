extends Node2D

@onready var slime_scene = preload('res://scenes/enemies/slime.tscn')
@onready var slime_spawn_positions = [
	$SlimeSpawnPos,
	$SlimeSpawnPos2,
	$SlimeSpawnPos3
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#spawn_slime()

func spawn_slime():
	var new_slime = slime_scene.instantiate()
	new_slime.global_position = slime_spawn_positions.pick_random().global_position
	add_child(new_slime)


func _on_dungeon_entrance_body_entered(body):
	g.enter_dungeon()
