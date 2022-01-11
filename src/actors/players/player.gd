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
	return Vector2(
		Input.get_action_strength(_player_input("move_right")) - Input.get_action_strength(_player_input("move_left")),
		-1 if is_on_floor() and Input.is_action_just_pressed(_player_input("jump")) else (1.0 if Input.is_action_pressed(_player_input("down")) else 0.0)
	)

func _handle_movement(input_dir: Vector2) -> void:
	"""Given the current input direction and current move state, apply the proper move state and velocity."""
	if input_dir.y == -1:
		_velocity.y = input_dir.y * speed.y
		_current_move_state = MOVE_STATE.JUMPING
	elif input_dir.y == 1:
		if _current_move_state != MOVE_STATE.JUMPING:
			_current_move_state = MOVE_STATE.CROUCHING
			_velocity.x = 0.0
	else:
		if _current_move_state == MOVE_STATE.JUMPING and not is_on_floor():
			return
			
		if input_dir.x != 0.0:
			_velocity.x = input_dir.x * speed.x
			_current_move_state = MOVE_STATE.WALKING
		else:
			_velocity.x = 0.0
			_current_move_state = MOVE_STATE.IDLING

func _handle_animation() -> void:
	"""Based on the previous state and current state, travel to the proper animation state."""
	pass

func _physics_process(delta: float) -> void:
	pass

func _process(delta: float) -> void:
	var input_direction = _get_input_direction()
	
	_handle_movement(input_direction)
	
	if _last_move_state != _current_move_state:
		$State.text = String(_current_move_state)
		print("new state {state}".format({"state": _current_move_state}))
	_last_move_state = _current_move_state
