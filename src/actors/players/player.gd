extends Actor

onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

# Player selection variables
export(int, 1, 2) var player_number := 1

var _damage_cool_down := 0.25 # How many seconds after being damaged are you invincible
onready var _attacks := $Attacks.get_children() # Loads attacks from nodes

func _ready():
	print("{name} (Player {player_number}): Recognized {attack_count} attacks".format({
		"name": name,
		"player_number": player_number,
		"attack_count": len(_attacks)
	}))

func _player_input(input_name: String) -> String:
	"""Returns the input prefix for this player for a particular input."""
	return "player_" + String(player_number) + "_" + input_name

func _physics_process(delta):
	pass
	
func _process(delta):
	pass
