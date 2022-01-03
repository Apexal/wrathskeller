class_name Attack
extends Node

export(String) var animation_name := ""
export(Array) var inputs := []
export(float) var cooldown_time := 0.4
export(float) var damange := 5.0

func _get_configuration_warning() -> String:
	var warnings = []
	if animation_name == "":
		warnings.append("Animation name is missing")
	
	return PoolStringArray(warnings).join(", ")
