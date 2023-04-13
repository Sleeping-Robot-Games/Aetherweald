extends Node2D

var target_pos: Vector2
var direction: Vector2
var speed: float = 100.0
var moving = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("spawn")
	direction = (target_pos - global_position).normalized()  # Calculate the initial direction based on target_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_in_direction(delta)

# Move the bullet in the direction calculated at the start
func move_in_direction(delta):
	if not moving:
		return

	global_position += direction * speed * delta

func _on_area_2d_body_entered(body):
	if body.name == 'Player':
		moving = false
		body.dmg(1)
		$AnimationPlayer.play('pop')

func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'spawn':
		$AnimationPlayer.play("float")
	if anim_name == 'pop':
		moving = false
		queue_free()

func _on_pop_timer_timeout():
	moving = false
	$AnimationPlayer.play('pop')
