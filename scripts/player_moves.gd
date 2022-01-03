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
#	{
#		"name": "Taunt",
#		"type": TAUNT,
#		"animation_name": "taunt1",
#		"inputs": ["taunt"],
#		"damage": 1.0
#	}
]

# Custom moves
const frankMoves = []

const playerMoves = {
	"frank": baseMoves + frankMoves
}
