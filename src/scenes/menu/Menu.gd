extends Control

func _ready():
	$Buttons/Training.grab_focus()

func _on_StartButton_pressed():
#	get_tree().change_scene("res://levels/Level1.tscn")
	pass

func _on_QuitButton_pressed():
	# Quit the game
	get_tree().quit()

func _on_TrainingButton_pressed():
	get_tree().change_scene("res://src/scenes/training/TrainingLevel.tscn")
