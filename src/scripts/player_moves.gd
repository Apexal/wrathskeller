extends Node

enum {ATTACK, BLOCK, TAUNT}

# Every player needs to have these moves animated
const baseMoves = [
	{
		"name": "Block",
		"type": BLOCK,
		"animation_name": "block",
		"inputs": ["block"]
	},
	{
		"name": "Punch",
		"type": ATTACK,
		"animation_name": "punch",
		"inputs": ["attack"],
		"damage": 5.0
	},
	{
		"name": "Kick",
		"type": ATTACK,
		"animation_name": "kick",
		"inputs": ["special"],
		"damage": 10.0
	}
]

# Custom moves
const frankMoves = []

const playerMoves = {
	"frank": baseMoves + frankMoves
}
