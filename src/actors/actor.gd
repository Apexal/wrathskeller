"""
An Actor represents a kinematic body that is affected by gravity and has health.

Players inherit from Actor, and NPCs would also inherit from Actor.
"""
class_name Actor
extends KinematicBody2D

signal health_changed
signal died
signal entered

const FLOOR_NORMAL = Vector2.UP # The direction of the floor, for move_and_slide

var speed := Vector2(150.0, 850.0) # x is walk speed, y is jump speed
var gravity := float(ProjectSettings.get_setting("physics/2d/default_gravity"))
var max_health := 100.0
var is_frozen := false

# TODO: Use
const DAMAGE_COOL_DOWN := 0.5 # How many seconds after being damaged are you invincible

var _health := max_health
var _is_alive := true # Always check this before doing things!
var _damage_knockback := Vector2(100, -500)

var _state_sound_effects := {}

var _velocity := Vector2.ZERO # Movement velocity

var target_to_face: KinematicBody2D # If set, will always face this body
var _is_flipped := true # Used to determine when to flip to face target
const _flip_delay := 2
var _flip_timer := _flip_delay

onready var _actions := $Actions.get_children() # Loads actions from nodes

const NO_ACTION = -1
var _current_action_index := NO_ACTION

# Must be kept in same order as STATES array in CharacterManager
enum MOVE_STATE {IDLE, ENTER, WALK, DASH, JUMP, CROUCH, BLOCK, GRAPPLED, HURT, WIN, LOSE}

var _current_move_state: int = MOVE_STATE.IDLE
var _last_move_state: int = MOVE_STATE.IDLE
onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

func enter() -> void:
	"""Freeze the character and perform their enter animation"""
	# TODO: pause until done, not just 5 seconds
	_current_move_state = MOVE_STATE.ENTER
	is_frozen = true
	yield(get_tree().create_timer(5), "timeout")
	is_frozen = false
	emit_signal("entered")

func take_damage(damage_amount: float) -> float:
	"""
	Inflicts `damage_amount` damage on the actor. If health drops below 0,
	`_is_alive` is set to false. The health after damage is always returned.
	
	When `_is_alive` is false or damage is a negative amount, this has no effect.
	"""
	if _current_move_state == MOVE_STATE.HURT:
		return _health
	
	if not _is_alive:
		return 0.0
	
	# Don't allow negative damage (healing)
	if damage_amount < 0:
		return _health
	
	_health -= damage_amount
	emit_signal("health_changed", _health)
	
	# Detect DEATH ;(
	if _health <= 0:
		_health = 0
		_is_alive = false
		emit_signal("died") # he dead
	
	# Apply knockback in the proper direction
	_velocity = _damage_knockback * Vector2(-1, 1) if _is_flipped else _damage_knockback
	
	_current_move_state = MOVE_STATE.HURT
	print("HURT")
	yield(get_tree().create_timer(DAMAGE_COOL_DOWN), "timeout")
	print("DONE HURTING")
	_current_move_state = MOVE_STATE.IDLE
	
	
	return _health

func _face_target(delta):
	"""After flip_timer seconds, flips the actor to face its target if it is set."""
	if target_to_face:
		if (_is_flipped and position.x > target_to_face.position.x) or (not _is_flipped and position.x < target_to_face.position.x):
			_flip_timer -= delta
			if _flip_timer <= 0.0:
				_flip_timer = _flip_delay
				_is_flipped = not _is_flipped
				scale.x = -1

func _start_action(action_index: int):
	"""Start an action, wait for it to complete, and end the action. Also plays action sound effect if applicable."""
	_current_action_index = action_index
	
	# If an audio stream is set, play it
	if _actions[_current_action_index].sound_effect:
		$AudioStreamPlayer.stream = _actions[_current_action_index].sound_effect
		$AudioStreamPlayer.play()
	
	# Wait till the action is complete
	yield(get_tree().create_timer(_actions[action_index].action_time), "timeout")
	
	# Reset so no action is set now
	_current_action_index = NO_ACTION

func _determine_move_state(input_dir: Vector2) -> void:
	"""Given the current input direction and current move state, apply the proper move state and velocity."""

	if _current_action_index != NO_ACTION:
		# Prevent moving when performing action unless midair
		if is_on_floor():
			_velocity.x = 0		
		return
	
	if _current_move_state == MOVE_STATE.HURT or is_frozen:
		return
	
	if input_dir.y == -1: # If attempting to JUMP
		if _current_move_state != MOVE_STATE.CROUCH:
			# Only jump if not crouching
			_velocity.y = input_dir.y * speed.y
			_current_move_state = MOVE_STATE.JUMP
	elif input_dir.y == 1:
		# Otherwise, if attempting to crouch
		# only crouch if not jumping, or landing from a jump
		if _current_move_state != MOVE_STATE.JUMP or (_current_move_state == MOVE_STATE.JUMP and is_on_floor()):
			_current_move_state = MOVE_STATE.CROUCH
			_velocity.x = 0.0
	else:
		# If mid-air, can't change velocity
		if _current_move_state == MOVE_STATE.JUMP and not is_on_floor():
			return
		
		# Apply movement and idle
		if input_dir.x != 0.0:
			_velocity.x = input_dir.x * speed.x
			_current_move_state = MOVE_STATE.WALK
		else:
			_velocity.x = 0.0
			_current_move_state = MOVE_STATE.IDLE

func _determine_animation(move_state: int, action_index: int) -> void:
	"""Based on the previous state and current state, travel to the proper animation state."""
	if _is_alive:
		if action_index != NO_ACTION: 
			state_machine.travel(_actions[action_index].animation_name)
		else:
			state_machine.travel(CharacterManager.STATES[move_state])
	else:
		state_machine.travel(CharacterManager.STATES[MOVE_STATE.LOSE])		

func _physics_process(delta):
	"""
	This is called after other _physics_process methods that are defined on classes that extend Actor.
	
	It applies gravity to the current velocity, applies the velocity, and faces the target. 
	"""
	
	
	_face_target(delta)
	_velocity.y += gravity
	_velocity.y = min(1000, _velocity.y) # Terminal velocity
	
	move_and_slide(_velocity, FLOOR_NORMAL)
