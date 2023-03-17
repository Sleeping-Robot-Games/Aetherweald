extends BaseState

@export var idle_node: NodePath
@export var roll_node: NodePath
@export var run_node: NodePath
@export var sword_light3_node: NodePath
@onready var idle_state: BaseState = get_node(idle_node)
@onready var roll_state: BaseState = get_node(roll_node)
@onready var run_state: BaseState = get_node(run_node)
@onready var sword_light3_state: BaseState = get_node(sword_light3_node)

var is_done: bool = false
var is_combo: bool = false
var is_rolling: bool = false
var combo_window: float = 0.3
var speed: float = 25.0
var attack_dir: Vector2 = Vector2.ZERO
var input_dir: Vector2 = Vector2.ZERO

func enter() -> void:
	super.enter()
	is_done = false
	is_combo = false
	is_rolling = false
	attack_dir = actor.direction

func input(event: InputEvent) -> BaseState:
	if event.is_action_pressed('light_attack') \
	and animation_player.current_animation_position <= combo_window:
		is_combo = true
	elif event.is_action_pressed('roll'):
		is_rolling = true
	return null

func connect_anim_player() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(_anim_name: String) -> void:
	is_done = true

func physics_process(_delta: float) -> BaseState:
	var is_donezo = is_done \
		or (is_combo and animation_player.current_animation_position >= combo_window)
	
	# update direction if holding input and exiting state
	if is_rolling or is_donezo:
		input_dir = Input.get_vector('left', 'right', 'up', 'down')
		if input_dir != Vector2.ZERO:
			actor.direction = input_dir
	
	if is_rolling:
		return roll_state
	elif is_donezo:
		if is_combo:
			return sword_light3_state
		elif input_dir == Vector2.ZERO:
			return idle_state
		else:
			return run_state
	else:
		actor.velocity = attack_dir * speed
		actor.move_and_slide()
	return null
