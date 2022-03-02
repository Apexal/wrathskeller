extends Actor

onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

# Player selection variables
export(int, 1, 2) var player_number := 1

const DAMAGE_COOL_DOWN := 0.25 # How many seconds after being damaged are you invincible
onready var _attacks := $Attacks.get_children() # Loads attacks from nodes

enum MOVE_STATE {IDLING, WALKING, JUMPING, CROUCHING}
var _current_move_state: int = MOVE_STATE.IDLING
var _last_move_state: int = MOVE_STATE.IDLING

const NO_ATTACK = -1
var _current_attack_index := NO_ATTACK

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
 
func _determine_attack() -> void:
	if _current_attack_index == NO_ATTACK:
		for i in len(_attacks):
			var attack: Attack = _attacks[i]
			var all_inputs_active := true
			for input in attack.inputs:
				if not Input.is_action_pressed(_player_input(input)):
					all_inputs_active = false
			
			# If all inputs for this move are active, make it the current attack
			if all_inputs_active:
				_start_attack(i)
				break # No need to continue looping

func _start_attack(attack_index: int):
	"""Start an attack, wait for it to complete, and end the attack."""
	_current_attack_index = attack_index
	yield(get_tree().create_timer(0.5), "timeout")
	_current_attack_index = NO_ATTACK

func _determine_movement(input_dir: Vector2) -> void:
	"""Given the current input direction and current move state, apply the proper move state and velocity."""
	
	if _current_attack_index != NO_ATTACK:
		# Prevent moving when attacking unless midair
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

func _determine_animation() -> void:
	"""Based on the previous state and current state, travel to the proper animation state."""
	if _current_attack_index != NO_ATTACK: 
		state_machine.travel(_attacks[_current_attack_index].animation_name)
	elif _current_move_state == MOVE_STATE.IDLING or _current_move_state == MOVE_STATE.WALKING:
		state_machine.travel("idle")
	elif _current_move_state == MOVE_STATE.CROUCHING:
		state_machine.travel("crouch")

func _process(delta: float) -> void:
	var input_direction = _get_input_direction()

	_determine_attack()
	_determine_movement(input_direction)
	_determine_animation()
	
	$State.text = "Move: " + String(_current_move_state)
	$Attack.text = "Attack: " + String(_current_attack_index)
	
