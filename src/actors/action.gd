class_name Action
extends Node

export(String) var animation_name := ""
export(float, 0.0, 100.0) var damage := 10.0
export(AudioStream) var sound_effect
export(float, 0.1, 10.0) var action_time := 0.5
export(String, "light_punch", "light_kick", "special", "heavy_special") var type
