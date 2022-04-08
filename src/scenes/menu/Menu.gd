extends Control

onready var first_focus := $Buttons/Quit

func _stop_bg_music():
	$"/root/BackgroundMusic".stop()

func _ready():
	first_focus.grab_focus()

func _on_TestingButton_pressed():
	CharacterManager.player1 = "character.wrath"
	CharacterManager.player2 = "character2.wrath"
	get_tree().change_scene("res://src/scenes/characters/test_characters/TestCharacters.tscn")

func _on_Controls_pressed():
	get_tree().change_scene("res://src/scenes/controls/Controls.tscn")
	
func _on_QuitButton_pressed():
	# Quit the game
	get_tree().quit()



