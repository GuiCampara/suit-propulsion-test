extends Node


var score: int = 0

@onready var score_label: Label = $ScoreLabel

func add_point():
	score += 1
	score_label.text = "Congrats! You collected " + str(score) + " coins"
