class_name Prop
extends RigidBody2D

@export var broken_frame: int
@export var is_breakable: bool
@export var is_despawnable: bool
@export var is_interactable: bool
@export var hp: int
@export var hit_sfx: String
@export var break_sfx: String
@export var loot_table: Dictionary # key = percentiles, value = array of scene names
var spawn: Vector2i
@onready var level = get_parent()
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func dmg(num: int, _dir: Vector2 = Vector2.ZERO, _force: float = 0.0) -> void:
	if is_breakable and hp > 0:
		hp = maxi(0, hp - num)
		if hp == 0:
			set_collision_layer_value(3, false)
			call_deferred('set_freeze_enabled', true)
			#$CollisionShape2D.disabled = true
			if broken_frame:
				$Sprite2D.frame = broken_frame
			if break_sfx:
				g.play_sfx(level, break_sfx)
			if loot_table.size() > 0:
				spawn_loot()
			if is_despawnable:
				$DespawnTimer.start()
			if level.has_method('prop_broken'):
				level.prop_broken(spawn)
		elif hit_sfx:
			g.play_sfx(level, hit_sfx)


func spawn_loot() -> void:
	rng.randomize()
	var percentile: int = rng.randi_range(1, 100)
	for key in loot_table:
		if percentile <= key:
			for loot in loot_table[key]:
				var loot_scene = load('res://scenes/loot/' + loot + '.tscn')
				var loot_instance = loot_scene.instantiate()
				loot_instance.global_position = global_position
				level.call_deferred('add_child', loot_instance)
			return


func init_broken() -> void:
	hp = 0
	set_collision_layer_value(3, false)
	call_deferred('set_freeze_enabled', true)
	#$CollisionShape2D.disabled = true
	if broken_frame:
		$Sprite2D.frame = broken_frame


func interact() -> void:
	pass


func _on_despawn_timer_timeout() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate:a", 0, 1)
	tween.tween_callback(queue_free)


func _on_interaction_area_body_entered(body):
	if is_interactable and body.name == 'Player' \
	and body.current_interactable == null:
		$InteractionIcon.visible = true
		body.current_interactable = self


func _on_interaction_area_body_exited(body):
	if is_interactable and body.name == 'Player' \
	and body.current_interactable == self:
		$InteractionIcon.visible = false
		body.current_interactable = null
