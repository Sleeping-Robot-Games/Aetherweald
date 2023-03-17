extends BaseState

@export var run_node: NodePath
@export var sword_heavy1_node: NodePath
@export var sword_light1_node: NodePath
@onready var run_state: BaseState = get_node(run_node)
@onready var sword_heavy1_state: BaseState = get_node(sword_heavy1_node)
@onready var sword_light1_state: BaseState = get_node(sword_light1_node)

func input(event: InputEvent) -> BaseState:
	if event.is_action_pressed('heavy_attack'):
		return sword_heavy1_state
	elif event.is_action_pressed('light_attack'):
		return sword_light1_state
	return null

func physics_process(_delta: float) -> BaseState:
	input_dir = get_input_dir()
	if input_dir != Vector2.ZERO:
		return run_state
	return null
