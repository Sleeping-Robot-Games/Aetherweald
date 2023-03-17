extends BaseState

@export var idle_node: NodePath
@export var run_node: NodePath
@export var sword_light3_node: NodePath
@onready var idle_state: BaseState = get_node(idle_node)
@onready var run_state: BaseState = get_node(run_node)
@onready var sword_light3_state: BaseState = get_node(sword_light3_node)

var is_done: bool = false
var is_combo: bool = false
var combo_window: float = 0.3
var attack_dir: Vector2 = Vector2.ZERO
var speed: float = 25.0

func enter() -> void:
	super.enter()
	is_done = false
	is_combo = false
	attack_dir = actor.direction

func input(event: InputEvent) -> BaseState:
	if event.is_action_pressed('light_attack') \
	and animation_player.current_animation_position <= combo_window:
		is_combo = true
	return null

func connect_anim_player() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
	is_done = true

func physics_process(_delta: float) -> BaseState:
	if is_done:
		var input_dir: Vector2 = Input.get_vector('left', 'right', 'up', 'down')
		if is_combo:
			actor.direction = input_dir
			return sword_light3_state
		elif input_dir == Vector2.ZERO:
			return idle_state
		else:
			actor.direction = input_dir
			return run_state
	else:
		actor.velocity = attack_dir * speed
		actor.move_and_slide()
	return null
