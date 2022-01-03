extends Node

const baseMoves = [
	{
		"name": "Punch",
		"animation_name": "punch",
		"inputs": ["attack"],
		"damage": 5.0
	}
]

const frankMoves = []

const playerMoves = {
	"frank": baseMoves + frankMoves
}
