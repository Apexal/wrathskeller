class_name Attack
extends Node

export(String) var animation_name := ""
export(float) var damage := 10.0
export(AudioStream) var default_audio
export(Dictionary) var per_character_audio

func _get_configuration_warning():
	if animation_name == "":
		return "Missing animation name"
	return ""
