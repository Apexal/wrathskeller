extends Actor

onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

# Player selection variables
export(int, 1, 2) var player_number := 1

const DAMAGE_COOL_DOWN := 0.25 # How many seconds after being damaged are you invincible
onready var _actions := $Actions.get_children() # Loads actions from nodes

enum MOVE_STATE {IDLING, WALKING, DASHING, JUMPING, CROUCHING, BLOCKING}
var _current_move_state: int = MOVE_STATE.IDLING
var _last_move_state: int = MOVE_STATE.IDLING

const NO_ACTION = -1
var _current_action_index := NO_ACTION

func _ready() -> void:
	print("Player {player_number} ({name}): Recognized {action_count} actions".format({
		"name": name,
		"player_number": player_number,
		"action_count": len(_actions)
	}))

func _player_input(input_name: String) -> String:
	"""Returns the input prefix for this player for a particular input."""
	return "player_" + String(player_number) + "_" + input_name

func _get_input_direction() -> Vector2:
	"""
	Checks the currently activated inputs and represents them as a vector.
	
	x is horizontal
	y+ is crouch
	y- is jump
	"""
	return Vector2(
		Input.get_action_strength(_player_input("move_right")) - Input.get_action_strength(_player_input("move_left")),
		-1 if is_on_floor() and Input.is_action_just_pressed(_player_input("jump")) else (1.0 if Input.is_action_pressed(_player_input("down")) else 0.0)
	)
 
func _determine_action() -> void:
	if _current_action_index == NO_ACTION:
		for i in len(_actions):
			var action: Action = _actions[i]
			if Input.is_action_just_pressed(_player_input(action.type)):
				_start_action(i)
				break # No need to continue looping

func _start_action(action_index: int):
	"""Start an action, wait for it to complete, and end the action."""
	_current_action_index = action_index
	yield(get_tree().create_timer(_actions[action_index].action_time), "timeout")
	_current_action_index = NO_ACTION

func _determine_movement(input_dir: Vector2) -> void:
	"""Given the current input direction and current move state, apply the proper move state and velocity."""

	if _current_action_index != NO_ACTION:
		# Prevent moving when performing action unless midair
		if is_on_floor():
			_velocity.x = 0		
		return

	if input_dir.y == -1: # If attempting to JUMP
		if _current_move_state != MOVE_STATE.CROUCHING:
			# Only jump if not crouching
			_velocity.y = input_dir.y * speed.y
			_current_move_state = MOVE_STATE.JUMPING
	elif input_dir.y == 1:
		# Otherwise, if attempting to crouch
		# only crouch if not jumping, or landing from a jump
		if _current_move_state != MOVE_STATE.JUMPING or (_current_move_state == MOVE_STATE.JUMPING and is_on_floor()):
			_current_move_state = MOVE_STATE.CROUCHING
			_velocity.x = 0.0
	else:
		# If mid-air, can't change velocity
		if _current_move_state == MOVE_STATE.JUMPING and not is_on_floor():
			return
		
		# Apply movement and idle
		if input_dir.x != 0.0:
			_velocity.x = input_dir.x * speed.x
			_current_move_state = MOVE_STATE.WALKING
		else:
			_velocity.x = 0.0
			_current_move_state = MOVE_STATE.IDLING

func _determine_animation(move_state: int, action_index: int) -> void:
	"""Based on the previous state and current state, travel to the proper animation state."""
	if action_index != NO_ACTION: 
		state_machine.travel(_actions[action_index].animation_name)
	elif move_state == MOVE_STATE.IDLING:
		state_machine.travel("idle")
	elif move_state == MOVE_STATE.WALKING:
		state_machine.travel("walk")
	elif move_state == MOVE_STATE.CROUCHING:
		state_machine.travel("crouch")
	elif move_state == MOVE_STATE.JUMPING:
		state_machine.travel("jump")

func _process(delta: float) -> void:
	var input_direction = _get_input_direction()

	_determine_action()
	_determine_movement(input_direction)
	_determine_animation(_current_move_state, _current_action_index)

	$State.text = "Move: " + String(_current_move_state)
	$Action.text = "Action: " + String(_current_action_index)
