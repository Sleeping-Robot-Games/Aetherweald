extends Node2D

var room_coord: Vector2i = Vector2i(0,0)
var entering_from: Vector2i = Vector2i(0,0)
var blueprint_name: String = 'tutorial_a';
var layers: Dictionary = {
	'black': 0,
	'ground': 1,
	'ground_objects': 2,
	'wall': 3,
	'wall_objects': 4,
	'sealed': 5,
}
var patterns: Dictionary = {
	'tl_corner': 0,
	'tr_corner': 1,
	'top_wall': 2,
	'top_door_open': 3,
	'top_door_sealed': 4,
	'side_wall': 5,
	'left_door_open': 6,
	'left_door_sealed': 7,
	'right_door_open': 8,
	'right_door_sealed': 9,
	'bl_corner': 10,
	'br_corner': 11,
	'bottom_wall': 12,
	'bottom_door_open': 13,
	'bottom_door_sealed': 14,
	'black': 15,
	'floor_dark': 16,
	'floor_mixed': 17,
	'floor_light': 18,
}
var tile_size = 16
@onready var blueprint: Dictionary = g.dungeon_blueprints[blueprint_name]
@onready var horz_door_left = blueprint.size.x / 2 - 4
@onready var horz_door_right = horz_door_left + 8
@onready var vert_door_top = blueprint.size.y / 2 - 4
@onready var vert_door_bottom = vert_door_top + 8
@onready var bot_row = blueprint.size.y + 1
var top_row = -5
var doors: Array = []

func _ready() -> void:
	generate_room()
	spawn_props()
	spawn_enemies()

func generate_room() -> void:
	$Camera2D.position = blueprint.size * tile_size / 2.0
	$TileMap.clear()
	determine_doors()
	move_player()
	paint_black()
	paint_ground()
	paint_walls()
	apply_door_state()


func determine_doors() -> void:
	doors = []
	var neighbor_coords: Dictionary = {
		'top': Vector2i(room_coord.x, room_coord.y - 1),
		'bottom': Vector2i(room_coord.x, room_coord.y + 1),
		'left': Vector2i(room_coord.x - 1, room_coord.y),
		'right': Vector2i(room_coord.x + 1, room_coord.y)
	}
	for neighbor in neighbor_coords:
		if g.dungeon_rooms.has(neighbor_coords[neighbor]):
			doors.append(neighbor)
			create_entrance(neighbor, neighbor_coords[neighbor])


func create_entrance(wall: String, dungeon_coord: Vector2i) -> void:
	var entrance = load('res://scenes/dungeon_entrance.tscn').instantiate()
	entrance.dungeon_coord = dungeon_coord
	entrance.entering_from = room_coord
	var spawn_tile: Vector2i = Vector2i.ZERO
	if wall == 'top':
		spawn_tile = Vector2i(horz_door_left + 1, top_row + 2)
	elif wall == 'bottom':
		spawn_tile = Vector2i(horz_door_left + 1, bot_row)
	elif wall == 'left':
		spawn_tile = Vector2i(-8, vert_door_top+6)
	elif wall == 'right':
		spawn_tile = Vector2i(blueprint.size.x + 2, vert_door_top + 6)
	entrance.global_position = map_to_global(spawn_tile)
	add_child(entrance)


func move_player() -> void:
	var player_dest: Vector2i = Vector2i.ZERO
	if entering_from == Vector2i.ZERO and room_coord == Vector2i.ZERO:
		# entering first room in dungeon
		player_dest = blueprint.size / 2
	elif entering_from.y < room_coord.y:
		# entering from top
		player_dest = Vector2i(horz_door_left + 4, 2)
	elif entering_from.y > room_coord.y:
		# entering from bottom
		player_dest = Vector2i(horz_door_left + 4, bot_row - 4)
	elif entering_from.x < room_coord.x:
		# entering from left
		player_dest = Vector2i(2, vert_door_top + 6)
	elif entering_from.x > room_coord.x:
		# entering from right
		player_dest = Vector2i(blueprint.size.x - 2, vert_door_top + 6)
	$Player.global_position = map_to_global(player_dest)


func map_to_global(tile_coord: Vector2i) -> Vector2i:
	return to_global($TileMap.map_to_local(tile_coord))


func paint_black() -> void:
	for col in range(-100, 100):
		for row in range(-100, 100):
			set_pattern('black', Vector2i(col, row), 'black')


func paint_ground() -> void:
	for col in range(1, blueprint.size.x + 1):
		for row in range(0, blueprint.size.y + 1):
			if col == 1 or col == blueprint.size.x \
			or row == 1 or row == blueprint.size.y \
			or row == 0:
				set_pattern('ground', Vector2i(col, row), 'floor_dark')
			elif row == 2 and col != 1 and col != blueprint.size.x:
				set_pattern('ground', Vector2i(col, row), 'floor_mixed')
			else:
				set_pattern('ground', Vector2i(col, row), 'floor_light')


func paint_walls() -> void:
	for col in range(0, blueprint.size.x + 2):
		# left wall
		if col == 0:
			set_pattern('wall', Vector2i(col, top_row), 'tl_corner')
			set_pattern('wall', Vector2i(col, bot_row), 'bl_corner')
			for row in range(0, blueprint.size.y + 1):
				if 'left' in doors:
					if row < vert_door_top or row > vert_door_bottom:
						set_pattern('wall', Vector2i(col, row), 'side_wall')
					elif row == vert_door_top:
						set_pattern('wall', Vector2i(col-2, row), 'left_door_open')
						set_pattern('sealed', Vector2i(col-2, row), 'left_door_sealed')
				else:
					set_pattern('wall', Vector2i(col, row), 'side_wall')
		# right wall
		elif col == blueprint.size.x + 1:
			set_pattern('wall', Vector2i(col-1, top_row), 'tr_corner')
			set_pattern('wall', Vector2i(col, bot_row), 'br_corner')
			for row in range(0, blueprint.size.y + 1):
				if 'right' in doors:
					if row < vert_door_top or row > vert_door_bottom:
						set_pattern('wall', Vector2i(col, row), 'side_wall')
					elif row == vert_door_top:
						set_pattern('wall', Vector2i(col, row), 'right_door_open')
						set_pattern('sealed', Vector2i(col, row), 'right_door_sealed')
				else:
					set_pattern('wall', Vector2i(col, row), 'side_wall')
		# top wall
		if 'top' in doors:
			if col == horz_door_left:
				set_pattern('wall', Vector2i(col, top_row-2), 'top_door_open')
				set_pattern('sealed', Vector2i(col, top_row-2), 'top_door_sealed')
			elif (col > 1 and col < horz_door_left) \
			or (col > horz_door_right and col < blueprint.size.x):
				set_pattern('wall', Vector2i(col, top_row), 'top_wall')
		elif col > 1 and col < blueprint.size.x:
			set_pattern('wall', Vector2i(col, top_row), 'top_wall')
		# bottom wall
		if 'bottom' in doors:
			if col == horz_door_left:
				set_pattern('wall', Vector2i(col, bot_row), 'bottom_door_open')
				set_pattern('sealed', Vector2i(col, bot_row), 'bottom_door_sealed')
			elif (col > 0 and col < horz_door_left) \
			or (col > horz_door_right and col < blueprint.size.x + 1):
				set_pattern('wall', Vector2i(col, bot_row), 'bottom_wall')
		elif col > 0 and col < blueprint.size.x + 1:
			set_pattern('wall', Vector2i(col, bot_row), 'bottom_wall')


func set_pattern(layer: String, coords: Vector2i, pattern: String) -> void:
	var p: TileMapPattern = $TileMap.tile_set.get_pattern(patterns[pattern])
	$TileMap.set_pattern(layers[layer], coords, p)


func spawn_props() -> void:
	for prop in g.dungeon_state[room_coord]['props']:
		var prop_scene = load('res://scenes/props/' + prop.scene)
		var prop_instance = prop_scene.instantiate()
		prop_instance.global_position = to_global($TileMap.map_to_local(prop.spawn))
		prop_instance.spawn = prop.spawn
		if prop.broken:
			prop_instance.init_broken()
		add_child(prop_instance)


func spawn_enemies() -> void:
	if g.dungeon_state[room_coord]['cleared']:
		return
	for enemy in blueprint.enemies:
		var enemy_scene = load('res://scenes/enemies/' + enemy.scene)
		var enemy_instance = enemy_scene.instantiate()
		enemy_instance.global_position = to_global($TileMap.map_to_local(enemy.spawn))
		enemy_instance.spawn = enemy.spawn
		add_child(enemy_instance)


func enemy_died(spawn) -> void:
	var all_dead = true
	for enemy in g.dungeon_state[room_coord]['enemies']:
		if enemy['spawn'] == spawn:
			enemy['dead'] = true
		elif enemy['dead'] == false:
			all_dead = false
	g.dungeon_state[room_coord]['cleared'] = all_dead
	apply_door_state()


func prop_broken(spawn) -> void:
	for prop in g.dungeon_state[room_coord]['props']:
		if prop['spawn'] == spawn:
			prop['broken'] = true


func apply_door_state() -> void:
	$TileMap.set_layer_enabled(layers['sealed'], \
	!g.dungeon_state[room_coord]['cleared'])
