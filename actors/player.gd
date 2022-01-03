extends KinematicBody2D
class_name Player
signal hit
signal health_changed

var _velocity := Vector2.ZERO
const FLOOR_NORMAL = Vector2.UP
export(Vector2) var speed := Vector2(150.0, 350.0)
onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
onready var gravity = 1000.0

const NO_MOVE = -1
var current_move_index := NO_MOVE

# Player selection variables
export(String, "frank") var player_move_set := "frank" # Determines the available moves and animations
export(int) var player_number := 1

# Health variables
export(float) var MAX_HEALTH = 100.0
var health = MAX_HEALTH

# Moveset for the selected player, is set in _ready
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
	
	if current_move_index == NO_MOVE and is_on_floor():
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
	if current_move_index == NO_MOVE:
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
	current_move_index = NO_MOVE

func take_damage(damage_amount: float):
	print("player " + String(player_number) + " takes " + String(damage_amount) + " damage")
	health -= damage_amount
	if health < 0:
		health = 0
	state_machine.travel("hurt")
	emit_signal("health_changed", player_number, health)

func _physics_process(delta):
	_velocity.y += gravity * delta
	move_and_slide(_velocity, FLOOR_NORMAL)

func _process(delta):
	var current_node = state_machine.get_current_node()
	var input_direction = get_direction()
	
	_velocity = calculate_move_velocity(_velocity, input_direction, speed, false)
	
	if current_move_index == NO_MOVE:
		if Input.is_action_pressed("player_1_down"):
			state_machine.travel("crouch")
		elif _velocity.x == 0:
			state_machine.travel("idle")
		else:
			state_machine.travel("walk")

	# When move animation is over, end move
	if current_move_index != NO_MOVE and current_node != moves[current_move_index]["animation_name"]:
		stop_current_move()
	
	var new_move_index = determine_move_index()
	
	if new_move_index != null:
		execute_move(new_move_index)


func _on_HitArea_body_entered(body):
	body.take_damage(moves[current_move_index]["damage"])
