extends CanvasLayer

@onready var upgrade_1: Button = $Panel/VBoxContainer/Upgrade1
@onready var upgrade_2: Button = $Panel/VBoxContainer/Upgrade2
@onready var upgrade_3: Button = $Panel/VBoxContainer/Upgrade3



var used_upgrades = []
var current_choices = []

var upgrades = {
	"Fire Rate Up": Callable(self, "_upgrade_fire_rate"),
	"Speed Up": Callable(self, "_upgrade_speed"),
	"Dash Cooldown Down": Callable(self, "_upgrade_dash"),
	"Spreadshot": Callable(self, "_upgrade_spreadshot"),
	"Big Bullets": Callable(self, "_upgrade_big_bullets"),
	"Crit Chance Up": Callable(self, "_upgrade_crit"),
	"Damage Up": Callable(self, "_upgrade_damage"),
	"Piercing Bullets": Callable(self, "_upgrade_piercing"),
	"Target Range Up": Callable(self, "_upgrade_target_range")
}


func _ready() -> void:
	visible = false


func show_menu() -> void:
	get_tree().paused = true
	visible = true
	
	current_choices.clear()
	var keys = upgrades.keys()
	keys = keys.filter(func(upgrade_name): return not used_upgrades.has(upgrade_name))
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
	if upgrade_name == "Spreadshot":
		used_upgrades.append("Spreadshot")
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
	
func _upgrade_damage(player):
	player.base_damage += 1
	used_upgrades.append("Damage Up")

func _upgrade_piercing(player):
	player.has_piercing = true
	used_upgrades.append("Piercing Bullets")
	
func _upgrade_target_range(player):
	player.target_range *= 1.1
