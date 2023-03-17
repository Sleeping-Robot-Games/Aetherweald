extends BaseState

@export var idle_node: NodePath
@export var run_node: NodePath
@export var sword_heavy2_node: NodePath
@onready var idle_state: BaseState = get_node(idle_node)
@onready var run_state: BaseState = get_node(run_node)
@onready var sword_heavy2_state: BaseState = get_node(sword_heavy2_node)

var is_done: bool = false
var is_combo: bool = false
var attack_dir: Vector2 = Vector2.ZERO
var speed: float = 25.0

func enter() -> void:
	super.enter()
	is_done = false
	is_combo = false
	attack_dir = actor.direction

func input(event: InputEvent) -> BaseState:
	if event.is_action_pressed('heavy_attack'):
		is_combo = true
	return null

func connect_anim_player() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
	print('anim_name: ' + anim_name)
	is_done = true

func physics_process(_delta: float) -> BaseState:
	if is_done:
		var input_dir: Vector2 = Input.get_vector('left', 'right', 'up', 'down')
		if is_combo:
			actor.direction = input_dir
			return sword_heavy2_state
		elif input_dir == Vector2.ZERO:
			return idle_state
		else:
			actor.direction = input_dir
			return run_state
	else:
		actor.velocity = attack_dir * speed
		actor.move_and_slide()
	return null
