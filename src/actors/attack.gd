class_name Attack
extends Node

export(String) var animation_name := ""
export(float, 0.0, 100.0) var damage := 10.0
export(AudioStream) var default_audio
export(float, 0.1, 10.0) var attack_time := 0.5
export(String, "light_punch", "light_kick", "special", "heavy_special") var type := "light_punch"

func _get_configuration_warning():
	if animation_name == "":
		return "Missing animation name"
	return ""
