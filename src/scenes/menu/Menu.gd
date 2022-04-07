extends Control

onready var first_focus := $Buttons/Quit

func _stop_bg_music():
	$"/root/BackgroundMusic".stop()

func _ready():
	first_focus.grab_focus()

func _on_TestingButton_pressed():
	get_tree().change_scene("res://src/scenes/characters/select_characters/SelectCharacters.tscn")

func _on_QuitButton_pressed():
	# Quit the game
	get_tree().quit()
