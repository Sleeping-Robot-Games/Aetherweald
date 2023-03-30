extends RigidBody2D
# TODO: extend props.gd, overwrite is_destructable & hp & loot dict

@export var broken_frame: int
@export var hp: int

var is_broken: bool = false

func dmg(num: int, _dir: Vector2 = Vector2.ZERO, _force: float = 0.0) -> void:
	print('rock hit')
	if not is_broken:
		hp = maxi(0, hp - num)
		if hp == 0:
			$Sprite2D.frame = broken_frame
			is_broken = true
			# TODO: spawn loot
			# disable collision
			set_collision_layer_value(3, false)
			call_deferred('set_freeze_enabled', true)
			# TODO: despawn?
			#$DespawnTimer.start()

func _on_despawn_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate:a", 0, 1)
	tween.tween_callback(queue_free)
