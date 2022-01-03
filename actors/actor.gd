class_name Actor
extends KinematicBody2D

export(Vector2) var speed = Vector2(150.0, 350.0)
onready var gravity = 1000.0

const FLOOR_NORMAL = Vector2.UP

var _velocity = Vector2.ZERO

func _physics_process(delta):
	# This is called after the inherited physics_process
	_velocity.y += gravity * delta
