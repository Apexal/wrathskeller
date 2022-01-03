class_name Player
extends Actor

onready var animation: AnimationPlayer = $AnimationPlayer
onready var attacks = $Attacks.get_children()

const NO_ATTACK = -1

var current_attack_index := NO_ATTACK
var time_since_last_attack := -1.0

export(int) var player_number := 1
export(float) var MAX_HEALTH = 100.0
var health = MAX_HEALTH

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
	
	if current_attack_index == NO_ATTACK and is_on_floor():
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

func determine_attack_index():
	if current_attack_index == NO_ATTACK:
		for i in len(attacks):
			var attack: Attack = attacks[i]
			if time_since_last_attack != -1.0 and time_since_last_attack < attack.cooldown_time:
				continue
			
			# Check if this attacks' input is pressed
			var all_inputs_pressed := true
			for input_suffix in attack.inputs:
				if not Input.is_action_pressed("player_" + String(player_number) + "_" + input_suffix):
					all_inputs_pressed = false
					break
			
			if all_inputs_pressed:
				return i

	return null

func execute_attack(attack_index: int):
	var attack: Attack = attacks[attack_index]
	current_attack_index = attack_index
	animation.play(attack.animation_name)
	time_since_last_attack = 0

func stop_current_attack():
	current_attack_index = NO_ATTACK
	animation.play("idle")

func take_damage(damage_amount: float):
	health -= damage_amount
	if health < 0:
		health = 0
	emit_signal("health_changed", health)

func _ready():
	animation.play("idle")

func _physics_process(delta):
	var input_direction = get_direction()
	
	_velocity = calculate_move_velocity(_velocity, input_direction, speed, false)
	move_and_slide(_velocity, FLOOR_NORMAL)

func _process(delta):
	var attack = determine_attack_index()
	
	if attack == null:
		time_since_last_attack += delta
	else:
		execute_attack(attack)

func _on_AnimationPlayer_animation_finished(anim_name):
	stop_current_attack()


func _on_Enemy_area_entered(area):
	print("OUCH")
