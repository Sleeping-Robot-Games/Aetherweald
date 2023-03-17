extends BaseState

@export var idle_node: NodePath
@export var roll_node: NodePath
@export var run_node: NodePath
@onready var idle_state: BaseState = get_node(idle_node)
@onready var roll_state: BaseState = get_node(roll_node)
@onready var run_state: BaseState = get_node(run_node)

var is_done: bool = false
var is_rolling: bool = false
var move_window: float = 0.2
var speed: float = 25.0
var attack_dir: Vector2 = Vector2.ZERO

func enter() -> void:
	super.enter()
	is_done = false
	is_rolling = false
	attack_dir = actor.direction

func input(event: InputEvent) -> BaseState:
	if event.is_action_pressed('roll'):
		is_rolling = true
	return null

func connect_anim_player() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(_anim_name: String) -> void:
	is_done = true

func physics_process(_delta: float) -> BaseState:
	var anim_seconds = animation_player.current_animation_position
	
	# update direction if holding input and exiting state
	if is_rolling or is_done:
		input_dir = get_input_dir()
		if input_dir != Vector2.ZERO:
			actor.direction = input_dir
	
	if is_rolling:
		return roll_state
	elif is_done:
		if input_dir == Vector2.ZERO:
			return idle_state
		else:
			actor.direction = input_dir
			return run_state
	elif anim_seconds <= move_window:
		actor.velocity = attack_dir * speed
		actor.move_and_slide()
	return null
