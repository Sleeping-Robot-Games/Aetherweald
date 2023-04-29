extends Prop

func interact() -> void:
	# TODO: trigger dungeon run end scene and calculations
	
	# clear current scene(s) excluding global singleton
	for child in get_tree().get_root().get_children():
		if child.name != 'g':
			child.queue_free()
	# load default game scene
	var game_scene = load('res://scenes/game.tscn').instantiate()
	get_tree().get_root().add_child(game_scene)
