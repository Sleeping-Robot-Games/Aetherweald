extends BaseState

@export var run_node: NodePath
@onready var run_state: BaseState = get_node(run_node)

func physics_process(_delta: float) -> BaseState:
	var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")
	if input_dir != Vector2.ZERO:
		return run_state
	return null
