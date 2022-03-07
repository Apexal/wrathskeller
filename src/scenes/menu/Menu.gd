extends Control

onready var first_focus := $Buttons/Training

func _stop_bg_music():
	$"/root/BackgroundMusic".stop()

func _ready():
	first_focus.grab_focus()

func _on_StartButton_pressed():
#	get_tree().change_scene("res://levels/Level1.tscn")
	pass

func _on_QuitButton_pressed():
	# Quit the game
	get_tree().quit()

func _on_TrainingButton_pressed():
	_stop_bg_music()
	get_tree().change_scene("res://src/scenes/training/TrainingLevel.tscn")
