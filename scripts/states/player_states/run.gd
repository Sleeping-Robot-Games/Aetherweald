extends BaseState

@export var idle_node: NodePath
@export var run_node: NodePath
@onready var idle_state: BaseState = get_node(idle_node)
@onready var run_state: BaseState = get_node(run_node)

var max_speed: float = 150.0
var accel: float = 40.0

func physics_process(_delta: float) -> BaseState:
	var prev_direction = actor.direction
	var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")
	actor.velocity = input_dir * max_speed
	actor.move_and_slide()
	
	if input_dir == Vector2.ZERO:
		return idle_state
	elif input_dir != prev_direction:
		actor.direction = input_dir
		return run_state
	
	actor.direction = input_dir
	return null
