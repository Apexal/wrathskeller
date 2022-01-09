extends Actor

onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

# Player selection variables
export(String) var player_name := ""
export(int) var player_number := 1

var _damage_cool_down := 0.25

func _ready():
	pass

func player_input(input_name: String) -> String:
	return "player_" + String(player_number) + "_" + input_name

func take_damage(damage_amount: float):
	pass

func _physics_process(delta):
	pass
	
func _process(delta):
	pass
