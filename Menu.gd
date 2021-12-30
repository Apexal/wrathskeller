extends Control

func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _on_StartButton_pressed():
	pass # Replace with function body.

func _on_LevelSelectButton_pressed():
	pass # Replace with function body.


func _on_QuitButton_pressed():
	# Quit the game
	get_tree().quit()


