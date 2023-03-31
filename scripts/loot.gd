extends RigidBody2D

@export var type: String = ''
var amount: int = 1
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	var x = rng.randi_range(30, 70) * ((rng.randi_range(0, 1) * 2) - 1)
	var y = rng.randi_range(-400, -600)
	linear_velocity = Vector2(x, y)
	$GravityTimer.start()

func _on_pickup_area_body_entered(body):
	if body.name == 'Player':
		body.get_loot(type, amount)
		queue_free()

func _on_gravity_timer_timeout():
	gravity_scale = 0
