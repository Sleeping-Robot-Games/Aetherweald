extends Node

@export var starting_state: NodePath

var current_state: BaseState

func change_state(new_state: BaseState) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()

# Initialize the state machine by giving each state a reference to the objects
# owned by the parent that they should be able to take control of
# and set a default state
func init(actor) -> void:
	var anim_player = get_parent().get_node('AnimationPlayer')
	for state in get_children():
		state.actor = actor
		state.animation_player = anim_player
		if state.has_method('connect_anim_player'):
			state.connect_anim_player()

	# Initialize with a default state of idle
	change_state(get_node(starting_state))
	
# Pass through functions handling state changes as needed
func _physics_process(delta: float) -> void:
	var new_state = current_state.physics_process(delta)
	if new_state:
		change_state(new_state)

func _input(event: InputEvent) -> void:
	var new_state = current_state.input(event)
	if new_state:
		change_state(new_state)

func _process(delta: float) -> void:
	var new_state = current_state.process(delta)
	if new_state:
		change_state(new_state)

