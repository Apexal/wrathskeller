extends Actor

# Player selection variables
var player_number := 1

func _ready() -> void:
	print("Player {player_number} ({name}): Recognized {action_count} actions".format({
		"name": name,
		"player_number": player_number,
		"action_count": len(_actions)
	}))
	print(_state_sound_effects)

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
	if not _is_alive or is_frozen:
		return Vector2.ZERO

	return Vector2(
		Input.get_action_strength(_player_input("move_right")) - Input.get_action_strength(_player_input("move_left")),
		-1 if is_on_floor() and Input.is_action_just_pressed(_player_input("jump")) else (1.0 if Input.is_action_pressed(_player_input("down")) else 0.0)
	)
 
func _determine_action() -> void:
	if not _is_alive:
		return

	if _current_action_index == NO_ACTION:
		for i in len(_actions):
			var action: Action = _actions[i]
			if Input.is_action_just_pressed(_player_input(action.type)):
				_start_action(i)
				break # No need to continue looping

func _process(delta: float) -> void:
	var input_direction = _get_input_direction()

	_determine_action()
	_determine_move_state(input_direction)
	_determine_animation(_current_move_state, _current_action_index)

	$State.text = "State: " + String(_current_move_state)
	$Action.text = "Action: " + String(_current_action_index)
	$Health.text = "Health: " + String(_health)

func _on_HitArea_body_entered(body):
	# Check that the body that entered this player's hit area is another player
	if body is Actor and _current_action_index != NO_ACTION:
		print(name, " hit ", body.name, " with action ", _actions[_current_action_index].name)
		body.take_damage(_actions[_current_action_index].damage)
