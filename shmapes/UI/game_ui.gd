extends CanvasLayer


const HEART_RED = preload("res://Assets/heart-red.png")
const HEART_GRAY = preload("res://Assets/heart-gray.png")
var score_label: Label
var score: int = 0
var next_level_score: int = 70

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

func add_score(points: int):
	score += points
	update_score_points(score)
	
	if score >= next_level_score:
		next_level_score += int(next_level_score * 1.02)
		var upgrade_menu = get_tree().current_scene.get_node("UpgradeMenu")
		upgrade_menu.show_menu()
	
	
