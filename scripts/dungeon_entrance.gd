extends Area2D

var dungeon_coord: Vector2i = Vector2i.ZERO
var entering_from: Vector2i = Vector2i.ZERO

func _on_body_entered(body):
	if body.name == 'Player':
		g.change_dungeon_room(dungeon_coord, entering_from)
