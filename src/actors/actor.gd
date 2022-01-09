class_name Actor
extends KinematicBody2D

# The direction of the floor, for move_and_slide
const FLOOR_NORMAL = Vector2.UP

export(Vector2) var speed := Vector2(150.0, 450.0) # x is walk speed, y is jump speed
export(float) var gravity := 1300.0
export(float) var max_health = 100.0

var _health: float = max_health
var _is_alive := true

var _velocity := Vector2.ZERO # Movement velocity

var target_to_face: KinematicBody2D # If set, will always face this body
var _is_facing_right := true # Used to determine when to flip to face target

func _face_target():
	# Always make sure to face the target, if set
	if target_to_face:
		if (_is_facing_right and position.x > target_to_face.position.x) or (not _is_facing_right and position.x < target_to_face.position.x):
			_is_facing_right = not _is_facing_right
			scale.x = -1

func _physics_process(delta):
	_velocity.y += gravity * delta
	move_and_slide(_velocity, FLOOR_NORMAL)
	_face_target()
