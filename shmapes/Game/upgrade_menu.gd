extends CanvasLayer

@onready var upgrade_1: Button = $Panel/VBoxContainer/Upgrade1
@onready var upgrade_2: Button = $Panel/VBoxContainer/Upgrade2
@onready var upgrade_3: Button = $Panel/VBoxContainer/Upgrade3




var current_choices = []

var upgrades = {
	"Fire Rate Up": Callable(self, "_upgrade_fire_rate"),
	"Speed Up": Callable(self, "_upgrade_speed"),
	"Dash Cooldown Down": Callable(self, "_upgrade_dash"),
	"Spreadshot": Callable(self, "_upgrade_spreadshot"),
	"Big Bullets": Callable(self, "_upgrade_big_bullets"),
	"Crit Chance Up": Callable(self, "_upgrade_crit")
}


func _ready() -> void:
	visible = false


func show_menu() -> void:
	get_tree().paused = true
	visible = true
	
	current_choices.clear()
	var keys = upgrades.keys()
	keys.shuffle()
	current_choices = keys.slice(0, 3)
	
	upgrade_1.text = current_choices[0]
	upgrade_2.text = current_choices[1]
	upgrade_3.text = current_choices[2]
	
	
func hide_menu() -> void:
	get_tree().paused = false
	visible = false
	
func _on_Upgrade1_pressed():
	apply_upgrades(current_choices[0])
	
func _on_Upgrade2_pressed():
	apply_upgrades(current_choices[1])
	
func _on_Upgrade3_pressed():
	apply_upgrades(current_choices[2])
	
func apply_upgrades(upgrade_name: String):
	var player = get_tree().current_scene.get_node("Jet")
	upgrades[upgrade_name].call(player)
	hide_menu()


func _upgrade_fire_rate(player):
	player.fire_rate *= 0.9

func _upgrade_speed(player):
	player.speed *= 1.1

func _upgrade_dash(player):
	player.dash_cooldown.wait_time *= 0.9

func _upgrade_spreadshot(player):
	player.enable_spreadshot()

func _upgrade_big_bullets(player):
	player.bullet_scale *= 1.1

func _upgrade_crit(player):
	player.crit_chance = clamp(player.crit_chance + 0.1, 0.0, 1.0)
