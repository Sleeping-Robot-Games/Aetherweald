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

var dungeon_blueprints: Dictionary = {
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
	},
	'tutorial_b': {
		'size': Vector2i(35, 18),
		'tileset': 0,
		'enemies': [
			{'scene': 'flooper.tscn', 'spawn': Vector2i(5,5)},
			{'scene': 'flooper.tscn', 'spawn': Vector2i(30,13)}
		],
		'props': [
			{'scene': 'stump.tscn', 'spawn': Vector2i(30,5)},
			{'scene': 'stump.tscn', 'spawn': Vector2i(5,13)}
		],
	},
	'tutorial_c': {
		'size': Vector2i(45, 18),
		'tileset': 0,
		'enemies': [
			{'scene': 'slime.tscn', 'spawn': Vector2i(5,5)},
			{'scene': 'flooper.tscn', 'spawn': Vector2i(40,13)}
		],
		'props': [
			{'scene': 'rock.tscn', 'spawn': Vector2i(40,5)},
			{'scene': 'stump.tscn', 'spawn': Vector2i(5,13)}
		],
	},
	'tutorial_d': {
		'size': Vector2i(45, 18),
		'tileset': 0,
		'enemies': [
			{'scene': 'flooper.tscn', 'spawn': Vector2i(5,5)},
			{'scene': 'slime.tscn', 'spawn': Vector2i(40,13)}
		],
		'props': [
			{'scene': 'stump.tscn', 'spawn': Vector2i(40,5)},
			{'scene': 'rock.tscn', 'spawn': Vector2i(5,13)}
		],
	},
	'exit_a': {
		'size': Vector2i(25, 15),
		'tileset': 0,
		'enemies': [],
		'props': [
			{'scene': 'exit_portal.tscn', 'spawn': Vector2i(10,8)},
		],
	},
}
var dungeon_state: Dictionary = {}
var dungeon_rooms: Dictionary = {}

func enter_dungeon() -> void:
	# TODO procedurally generate dungeon
	dungeon_state = {}
	dungeon_rooms = {
		Vector2i(0,0): 'tutorial_a',
		Vector2i(1,0): 'tutorial_b',
		Vector2i(-1,0): 'tutorial_c',
		Vector2i(1,-1): 'tutorial_d',
		Vector2i(0,-1): 'exit_a',
	}
	change_dungeon_room(Vector2i(0,0), Vector2i(0,0))

func change_dungeon_room(coord, from_coord) -> void:
	# if this room hasn't been entered yet, add it to dungeon state
	if not dungeon_state.has(coord):
		dungeon_state[coord] = dungeon_blueprints[dungeon_rooms[coord]]
		if dungeon_state[coord]['enemies'].size() == 0:
			dungeon_state[coord]['cleared'] = true
		else:
			dungeon_state[coord]['cleared'] = false
		for enemy in dungeon_state[coord]['enemies']:
			enemy['dead'] = false
		for prop in dungeon_state[coord]['props']:
			prop['broken'] = false
	# clear current scene(s) excluding global singleton
	for child in get_tree().get_root().get_children():
		if child.name != 'g':
			child.queue_free()
	# load new dungeon room
	var new_dungeon = load('res://scenes/dungeon.tscn').instantiate()
	new_dungeon.room_coord = coord
	new_dungeon.entering_from = from_coord
	new_dungeon.blueprint_name = dungeon_rooms[coord]
	get_tree().get_root().add_child(new_dungeon)
