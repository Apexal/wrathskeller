class_name Player
extends Actor

onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

const IDLE = -1

var current_move_index := IDLE

export(String, "frank") var player_move_set := "frank"
export(int) var player_number := 1
export(float) var MAX_HEALTH = 100.0
var health = MAX_HEALTH

var moves

func _ready():
	moves = PlayerMoves.playerMoves[player_move_set]
	print(String(len(moves)) + " moves recognized for " + player_move_set)

func get_direction():
	return Vector2(
		Input.get_action_strength("player_" + String(player_number) + "_move_right") - Input.get_action_strength("player_" + String(player_number) + "_move_left"),
		-1 if is_on_floor() and Input.is_action_just_pressed("player_" + String(player_number) + "_jump") else 0
	)

# This function calculates a new velocity whenever you need it.
# It allows you to interrupt jumps.
func calculate_move_velocity(
	linear_velocity,
	direction,
	speed,
	is_jump_interrupted
):
	var velocity = linear_velocity
	
	if current_move_index == IDLE and is_on_floor():
		velocity.x = speed.x * direction.x
	elif is_on_floor():
		velocity.x = 0
		
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		# Decrease the Y velocity by multiplying it, but don't set it to 0
		# as to not be too abrupt.
		velocity.y *= 0.6
	return velocity

func determine_move_index():
	if current_move_index == IDLE:
		for i in len(moves):
			var move = moves[i]
			
			# Check if this attacks' input is pressed
			var all_inputs_pressed := true
			for input_suffix in move["inputs"]:
				if not Input.is_action_pressed("player_" + String(player_number) + "_" + input_suffix):
					all_inputs_pressed = false
					break
			
			if all_inputs_pressed:
				return i

	return null

func execute_move(move_index: int):
	var move = moves[move_index]
	current_move_index = move_index
	state_machine.travel(move["animation_name"])

func stop_current_move():
	current_move_index = IDLE
	state_machine.travel("idle")

func take_damage(damage_amount: float):
	health -= damage_amount
	if health < 0:
		health = 0
	emit_signal("health_changed", health)

func _physics_process(delta):
	var input_direction = get_direction()
	
	_velocity = calculate_move_velocity(_velocity, input_direction, speed, false)
	move_and_slide(_velocity, FLOOR_NORMAL)

func _process(delta):
	if current_move_index != IDLE and state_machine.get_current_node() == "idle":
		stop_current_move()
	
	var new_move_index = determine_move_index()
	
	if new_move_index != null:
		execute_move(new_move_index)

func _on_Enemy_area_entered(area):
	print("OUCH")
