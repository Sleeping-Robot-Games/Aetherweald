extends Node2D

var room_type: String = 'tutorial_a';
var layers: Dictionary = {
	'black': 0,
	'ground': 1,
	'ground_objects': 2,
	'wall': 3,
	'wall_objects': 4,
}
var tile_size = 16
@onready var blueprint = g.room_blueprints[room_type]

func _ready() -> void:
	generate_room()
	spawn_enemies()
	spawn_props()

func set_cell(layer: String, coords: Vector2i, atlas_coords: Vector2i) -> void:
	$TileMap.set_cell(layers[layer], coords, blueprint.tileset, atlas_coords)

func generate_room() -> void:
	$Camera2D.position = blueprint.size * tile_size / 2.0
	$TileMap.clear()
	paint_black()
	paint_ground()
	paint_walls()
	paint_doors()

func paint_black() -> void:
	for col in range(-100, 100):
		for row in range(-100, 100):
			set_cell('black', Vector2i(col, row), Vector2i(4, 13))

func paint_ground() -> void:
	for col in range(1, blueprint.size.x + 1):
		for row in range(0, blueprint.size.y + 1):
			if col == 1 or col == blueprint.size.x \
			or row == 1 or row == blueprint.size.y \
			or row == 0:
				set_cell('ground', Vector2i(col, row), Vector2i(4, 9))
			elif row == 2 and col != 1 and col != blueprint.size.x:
				set_cell('ground', Vector2i(col, row), Vector2i(4, 10))
			else:
				set_cell('ground', Vector2i(col, row), Vector2i(4, 11))

func paint_walls() -> void:
	for col in range(0, blueprint.size.x + 2):
		# top
		for row in range(-6, 1):
			if row == -6:
				if col == 0:
					set_cell('wall', Vector2i(col, row), Vector2i(2, 2))
				elif col == 1:
					set_cell('wall', Vector2i(col, row), Vector2i(3, 2))
				elif col == blueprint.size.x + 1:
					set_cell('wall', Vector2i(col, row), Vector2i(10, 2))
				elif col == blueprint.size.x:
					set_cell('wall', Vector2i(col, row), Vector2i(9, 2))
				else:
					set_cell('wall', Vector2i(col, row), Vector2i(4, 2))
			elif row == -5:
				if col == 0:
					set_cell('wall', Vector2i(col, row), Vector2i(2, 3))
				elif col == 1:
					set_cell('wall', Vector2i(col, row), Vector2i(3, 3))
				elif col == blueprint.size.x + 1:
					set_cell('wall', Vector2i(col, row), Vector2i(10, 3))
				elif col == blueprint.size.x:
					set_cell('wall', Vector2i(col, row), Vector2i(9, 3))
				else:
					set_cell('wall', Vector2i(col, row), Vector2i(4, 3))
			elif row == 0:
				if col == 0:
					set_cell('wall', Vector2i(col, row), Vector2i(2, 7))
				elif col == 1:
					set_cell('wall', Vector2i(col, row), Vector2i(3, 7))
				elif col == blueprint.size.x + 1:
					set_cell('wall', Vector2i(col, row), Vector2i(10, 7))
				elif col == blueprint.size.x:
					set_cell('wall', Vector2i(col, row), Vector2i(9, 7))
				else:
					set_cell('wall', Vector2i(col, row), Vector2i(4, 7))
			else:
				if col == 0:
					set_cell('wall', Vector2i(col, row), Vector2i(2, 4))
				elif col == 1:
					set_cell('wall', Vector2i(col, row), Vector2i(3, 4))
				elif col == blueprint.size.x + 1:
					set_cell('wall', Vector2i(col, row), Vector2i(10, 4))
				elif col == blueprint.size.x:
					set_cell('wall', Vector2i(col, row), Vector2i(9, 4))
				else:
					set_cell('wall', Vector2i(col, row), Vector2i(4, 4))
		# sides
		for row in range(0, blueprint.size.y + 1):
			if col == 0 or col == blueprint.size.x + 1:
				set_cell('wall', Vector2i(col, row), Vector2i(2, 8))
		# bottom
		var row = blueprint.size.y + 1
		if col == 0:
			set_cell('wall', Vector2i(col, row), Vector2i(2, 22))
		elif col == blueprint.size.x + 1:
			set_cell('wall', Vector2i(col, row), Vector2i(10, 22))
		else:
			set_cell('wall', Vector2i(col, row), Vector2i(3, 22))

func paint_doors() -> void:
	pass

func spawn_enemies() -> void:
	for enemy in blueprint.enemies:
		var enemy_scene = load('res://scenes/enemies/' + enemy.scene)
		var enemy_instance = enemy_scene.instantiate()
		enemy_instance.global_position = to_global($TileMap.map_to_local(enemy.spawn))
		add_child(enemy_instance)

func spawn_props() -> void:
	for prop in blueprint.props:
		var prop_scene = load('res://scenes/props/' + prop.scene)
		var prop_instance = prop_scene.instantiate()
		prop_instance.global_position = to_global($TileMap.map_to_local(prop.spawn))
		add_child(prop_instance)
