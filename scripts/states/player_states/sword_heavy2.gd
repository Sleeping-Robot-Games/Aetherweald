extends BaseState

@export var idle_node: NodePath
@export var run_node: NodePath
@onready var idle_state: BaseState = get_node(idle_node)
@onready var run_state: BaseState = get_node(run_node)

var is_done: bool = false
var move_window: Dictionary = {
	'start': 0.4,
	'end': 0.6
}
var attack_dir: Vector2 = Vector2.ZERO
var speed: float = 300.0

func enter() -> void:
	super.enter()
	is_done = false
	attack_dir = actor.direction

func connect_anim_player() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(_anim_name: String) -> void:
	is_done = true

func physics_process(_delta: float) -> BaseState:
	var anim_seconds = animation_player.current_animation_position
	
	# update direction if holding input and exiting state
	if is_done:
		input_dir = get_input_dir()
		if input_dir != Vector2.ZERO:
			actor.direction = input_dir
			
	if is_done:
		if input_dir == Vector2.ZERO:
			return idle_state
		else:
			return run_state
	elif anim_seconds >= move_window.start and anim_seconds <= move_window.end:
		actor.velocity = attack_dir * speed
		actor.move_and_slide()
	return null
