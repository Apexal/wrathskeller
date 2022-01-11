extends Actor

onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

# Player selection variables
export(int, 1, 2) var player_number := 1

const _damage_cool_down := 0.25 # How many seconds after being damaged are you invincible
onready var _attacks := $Attacks.get_children() # Loads attacks from nodes

enum MOVE_STATE {IDLING, WALKING, JUMPING, CROUCHING}
var _current_move_state: int = MOVE_STATE.IDLING
var _last_move_state: int = MOVE_STATE.IDLING

func _ready() -> void:
	print("Player {player_number} ({name}): Recognized {attack_count} attacks".format({
		"name": name,
		"player_number": player_number,
		"attack_count": len(_attacks)
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
	
	# (0, 1) crouch
	# (0, -1) jump
	# (0, 0) in air
	# (0, 1) in air if holding down
 
func _handle_movement(input_dir: Vector2) -> void:
	"""Given the current input direction and current move state, apply the proper move state and velocity."""
	
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

func _handle_animation() -> void:
	"""Based on the previous state and current state, travel to the proper animation state."""
	if _current_move_state == MOVE_STATE.IDLING or _current_move_state == MOVE_STATE.WALKING:
		state_machine.travel("idle")
	elif _current_move_state == MOVE_STATE.CROUCHING:
		state_machine.travel("crouch")

func _process(delta: float) -> void:
	var input_direction = _get_input_direction()
	
	_handle_movement(input_direction)
	_handle_animation()
	
	if _last_move_state != _current_move_state:
		$State.text = String(_current_move_state)
	_last_move_state = _current_move_state
