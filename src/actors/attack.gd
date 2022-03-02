class_name Attack
extends Node

export(String) var animation_name := ""
export(Array, String) var inputs := []
export(float, 0.0, 100.0) var damage := 10.0
export(AudioStream) var default_audio

func _get_configuration_warning():
	if animation_name == "":
		return "Missing animation name"
	return ""
