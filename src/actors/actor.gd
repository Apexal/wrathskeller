"""
An Actor represents a kinematic body that is affected by gravity and has health.

Players inherit from Actor, and NPCs would also inherit from Actor.
"""
class_name Actor
extends KinematicBody2D

signal health_changed
signal died

const FLOOR_NORMAL = Vector2.UP # The direction of the floor, for move_and_slide

var speed := Vector2(150.0, 850.0) # x is walk speed, y is jump speed
var gravity := float(ProjectSettings.get_setting("physics/2d/default_gravity"))
var max_health := 100.0

# TODO: Use
const DAMAGE_COOL_DOWN := 0.25 # How many seconds after being damaged are you invincible

var _health := max_health
var _is_alive := true # Always check this before doing things!
var _damage_knockback := Vector2(100, -200)

var _velocity := Vector2.ZERO # Movement velocity

var target_to_face: KinematicBody2D # If set, will always face this body
var _is_flipped := true # Used to determine when to flip to face target
const _flip_delay := 0.25
var _flip_timer := _flip_delay

func take_damage(damage_amount: float) -> float:
	"""
	Inflicts `damage_amount` damage on the actor. If health drops below 0,
	`_is_alive` is set to false. The health after damage is always returned.
	
	When `_is_alive` is false or damage is a negative amount, this has no effect.
	"""

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

func _physics_process(delta):
	"""
	This is called after other _physics_process methods that are defined on classes that extend Actor.
	
	It applies gravity to the current velocity, applies the velocity, and faces the target. 
	"""

	_face_target(delta)
	_velocity.y += gravity
	_velocity.y = min(1000, _velocity.y) # Terminal velocity
	move_and_slide(_velocity, FLOOR_NORMAL)
