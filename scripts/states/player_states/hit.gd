extends BaseState

@export var idle_node: NodePath
@export var run_node: NodePath
@onready var idle_state: BaseState = get_node(idle_node)
@onready var run_state: BaseState = get_node(run_node)

var is_done: bool = false

func enter() -> void:
	super.enter()
	is_done = false

func connect_anim_player() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(_anim_name: String) -> void:
	is_done = true

func physics_process(_delta: float) -> BaseState:
	if is_done:
		input_dir = get_input_dir()
		if input_dir != Vector2.ZERO:
			actor.direction = input_dir
		
		if input_dir == Vector2.ZERO:
			return idle_state
		else:
			return run_state
	
	return null
