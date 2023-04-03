extends Node

func play_sfx(level: Node2D, sfx: String, db_overide: float = 0.0):
	var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
	sfx_player.volume_db = db_overide
	sfx_player.stream = load('res://assets/sfx/' + get_sfx_file(sfx))
	sfx_player.finished.connect(sfx_player.queue_free)
	#TODO: figure out how to await call_deferred
	#level.call_deferred('add_child', sfx_player)
	level.add_child(sfx_player)
	sfx_player.play()

func get_sfx_file(sfx: String) -> String:
	var file: String = ''
	match sfx:
		'rock_hit':
			file = 'rock_hit.ogg'
		'rock_break':
			file = 'rock_break.ogg'
	return file

var room_blueprints: Dictionary = {
	'tutorial_a': {
		'size': Vector2i(45, 18),
		'tileset': 0,
		'enemies': [
			{'scene': 'slime.tscn', 'spawn': Vector2i(5,5)},
			{'scene': 'slime.tscn', 'spawn': Vector2i(40,13)}
		],
		'props': [
			{'scene': 'rock.tscn', 'spawn': Vector2i(40,5)},
			{'scene': 'rock.tscn', 'spawn': Vector2i(5,13)}
		],
		'doors': ['top', 'bottom'],
	}
}

var dungeon_rooms: Dictionary
