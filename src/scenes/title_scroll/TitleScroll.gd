extends Control

export(float) var speed = 40.0

onready var label = $Text
onready var animation = $AnimationPlayer

func _change_scene():
	# TODO: determine how to fade to black before changing
	get_tree().change_scene("res://src/scenes/menu/Menu.tscn")

func _ready():
	animation.play("Fade in")
	#animation.play_backwards("Fade in")
	
func _physics_process(delta):
	"""With every tick, move the label up by speed. If it is off screen, continue to next scene."""
	# Move label up by speed
	label.rect_position = Vector2(label.rect_position.x, label.rect_position.y - speed * delta)
	
	# If label is off screen, it is done
	if label.margin_bottom < 0:
		_change_scene()

func _input(event):
	"""If there is any input, end the scroll and go to the next scene."""
	if event.is_pressed():
		_change_scene()
