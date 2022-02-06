extends Control

export(float) var speed = 50.0

onready var label: RichTextLabel = $Text

func _change_scene():
#	set_modulate(lerp(get_modulate(), Color(0,0,0,1), 0.2))
#	if modulate == Color(0,0,0,1):
	get_tree().change_scene("res://src/scenes/menu/Menu.tscn")

func _physics_process(delta):
	"""With every tick, move the label up by speed. If it is off screen, continue to next scene."""
	
	# Move label up by speed
	label.rect_position = Vector2(label.rect_position.x, label.rect_position.y - speed * delta)
	
	if label.margin_bottom < 0:
		_change_scene()

func _input(event):
	"""If there is any input, end the scroll and go to the next scene."""
	if event.is_pressed():
		_change_scene()
