extends KinematicBody2D

onready var animatedSprite = $AnimatedSprite

const MAX_HEALTH = 100.0

var health = MAX_HEALTH

var attacks = [
	{
		"input": "ui_punch",
		"name": "Punch",
		"animation": "punch",
		"frameHandColliderPositions": {
			1: Vector2(89, -95)
		}
	}
]

const ATTACK_PUNCH = 1
const ATTACK_KICK = 2
const GRAVITY = 200.0
const MOVE_SPEED = 200

var currentAttackIndex = 0

const timeBetweenInputs = 0.4
var remainingAttackTime = 0
var velocity := Vector2.ZERO

func _ready():
	remainingAttackTime = timeBetweenInputs

func handle_movement(delta):
	velocity.y += delta * GRAVITY
	
	if currentAttackIndex == -1:
		if Input.is_action_pressed("ui_right"):
			velocity.x = MOVE_SPEED
		elif Input.is_action_pressed("ui_left"):
			velocity.x = -MOVE_SPEED
		else:
			velocity.x = 0
	else:
		velocity.x = 0

func _physics_process(delta):
	handle_movement(delta)	
	move_and_slide(velocity, Vector2(0, -1))

func _process(delta):
	if currentAttackIndex == -1:
		for attackIndex in len(attacks):
			var attack = attacks[attackIndex]
			if Input.is_action_pressed(attack["input"]):
				animatedSprite.play(attack["animation"])
				print(attack["name"])
			
				# play punch animation
				currentAttackIndex = attackIndex
		
			remainingAttackTime = timeBetweenInputs


	if currentAttackIndex > -1:
		remainingAttackTime -= delta
		
		if remainingAttackTime < 0:
			remainingAttackTime = timeBetweenInputs
			currentAttackIndex = -1
			animatedSprite.play("idle")			


