extends BaseState

@export var idle_node: NodePath
@export var run_node: NodePath
@onready var idle_state: BaseState = get_node(idle_node)
@onready var run_state: BaseState = get_node(run_node)

var is_done: bool = false
var roll_dir: Vector2 = Vector2.ZERO
var speed: float = 250.0

func enter() -> void:
	super.enter()
	is_done = false
	roll_dir = actor.direction
	actor.get_node('CollisionShape2D').disabled = true

func exit() -> void:
	actor.get_node('CollisionShape2D').disabled = false

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
	else:
		actor.velocity = roll_dir * speed
		actor.move_and_slide()
	return null
