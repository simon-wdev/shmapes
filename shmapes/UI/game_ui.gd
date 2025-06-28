extends CanvasLayer


const HEART_RED = preload("res://Assets/heart-red.png")
const HEART_GRAY = preload("res://Assets/heart-gray.png")
var score_label: Label
var score: int = 0

@onready var hearts = [
	$HeartContainer/Heart1,
	$HeartContainer/Heart2,
	$HeartContainer/Heart3
]

var level_table = []
var current_level = 0
var growth = 1.25

func generate_level_table():
	var level_score = 100
	var increment = 120
	for i in range(50):
		level_table.append(level_score)
		level_score += increment
		increment += 20

func _ready() -> void:
	score_label = get_node("ScoreLabel")
	generate_level_table()
	
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
	
	if score >= level_table[current_level]:
		current_level += 1
		var upgrade_menu = get_tree().current_scene.get_node("UpgradeMenu")
		upgrade_menu.show_menu()
	
	
