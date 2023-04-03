extends Node

func play_sfx(level, sfx, db_overide = 0):
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = db_overide
	sfx_player.stream = load('res://assets/sfx/' + get_sfx_file(sfx))
	sfx_player.finished.connect(sfx_player.queue_free)
	#TODO: figure out how to await call_deferred
	#level.call_deferred('add_child', sfx_player)
	level.add_child(sfx_player)
	sfx_player.play()

func get_sfx_file(sfx: String) -> String:
	var file = ''
	match sfx:
		'rock_hit':
			file = 'rock_hit.ogg'
		'rock_break':
			file = 'rock_break.ogg'
	return file

var dungeon_rooms: Dictionary
