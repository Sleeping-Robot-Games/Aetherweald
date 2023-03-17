extends BaseState

@export var idle_node: NodePath
@export var roll_node: NodePath
@export var run_node: NodePath
@export var sword_heavy1_node: NodePath
@export var sword_light1_node: NodePath
@onready var idle_state: BaseState = get_node(idle_node)
@onready var roll_state: BaseState = get_node(roll_node)
@onready var run_state: BaseState = get_node(run_node)
@onready var sword_heavy1_state: BaseState = get_node(sword_heavy1_node)
@onready var sword_light1_state: BaseState = get_node(sword_light1_node)

var speed: float = 150.0

func input(event: InputEvent) -> BaseState:
	if event.is_action_pressed('roll'):
		return roll_state
	elif event.is_action_pressed('heavy_attack'):
		return sword_heavy1_state
	elif event.is_action_pressed('light_attack'):
		return sword_light1_state
	return null

func physics_process(_delta: float) -> BaseState:
	var prev_direction = actor.direction
	input_dir = get_input_dir()
	if input_dir != Vector2.ZERO:
		actor.direction = input_dir
	actor.velocity = input_dir * speed
	actor.move_and_slide()
	
	if input_dir == Vector2.ZERO:
		return idle_state
	elif input_dir != prev_direction:
		return run_state
	
	return null
