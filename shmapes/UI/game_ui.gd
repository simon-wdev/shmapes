extends CanvasLayer


const HEART_RED = preload("res://Assets/heart-red.png")
const HEART_GRAY = preload("res://Assets/heart-gray.png")
var score_label: Label

@onready var hearts = [
	$HeartContainer/Heart1,
	$HeartContainer/Heart2,
	$HeartContainer/Heart3
]

func _ready() -> void:
	score_label = get_node("ScoreLabel")
	
func update_hearts(current_health: int):
	for i in range(hearts.size()):
		if i < current_health:
			hearts[i].texture = HEART_RED
		else:
			hearts[i].texture = HEART_GRAY

func update_score_points(points: int):
	if score_label:
		score_label.text = "%06d" % points
