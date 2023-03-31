extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func dmg(num: int, dir: Vector2 = Vector2.ZERO, force: float = 0.0) -> void:
	$AnimationPlayer.play("hit")
