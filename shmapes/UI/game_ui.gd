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
	for i in range(25):
		level_table.append(level_score)
		level_score += increment
		increment += 80
		
	for i in range(25, 50):
		level_score += int(increment * 1.5)
		level_table.append(level_score)
		increment += 120
		
	for i in range(50, 100):
		level_score += int(increment * 1.5)
		level_table.append(level_score)
		increment += 150

func _ready() -> void:
	score_label = get_node("ScoreLabel")
	generate_level_table()
	
func update_hearts(current_health: int, max_health: int):
	while hearts.size() < max_health:
		var new_heart = hearts[0].duplicate()
		$HeartContainer.add_child(new_heart)
		hearts.append(new_heart)
		
	for i in range(hearts.size()):
		hearts[i].visible = i < max_health
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
	
	
