extends CanvasLayer

@onready var upgrade_1: Button = $Panel/VBoxContainer/Upgrade1
@onready var upgrade_2: Button = $Panel/VBoxContainer/Upgrade2
@onready var upgrade_3: Button = $Panel/VBoxContainer/Upgrade3



var used_upgrades = []
var current_choices = []

var upgrades = [
	{"name": "Fire Rate Up", "func": Callable(self, "_upgrade_fire_rate"), "weight": 22},
	{"name": "Speed Up", "func": Callable(self, "_upgrade_speed"), "weight": 20},
	{"name": "Dash Cooldown Down", "func": Callable(self, "_upgrade_dash"), "weight": 15},
	{"name": "Spreadshot", "func": Callable(self, "_upgrade_spreadshot"), "weight": 6},
	{"name": "Big Bullets", "func": Callable(self, "_upgrade_big_bullets"), "weight": 15},
	{"name": "Crit Chance Up", "func": Callable(self, "_upgrade_crit"), "weight": 12},
	{"name": "Damage Up",  "func": Callable(self, "_upgrade_damage"), "weight": 10},
	{"name": "Piercing Bullets Chance +", "func": Callable(self, "_upgrade_piercing"), "weight": 12},
	{"name": "Target Range Up", "func": Callable(self, "_upgrade_target_range"), "weight": 10},
	{"name": "Radial Multishot Chance+", "func": Callable(self, "_upgrade_radial_shot"), "weight": 8},
	{"name": "Max Life +", "func": Callable(self, "_upgrade_max_life"), "weight": 5},
	{"name": "Adrenaline Rush at 1HP", "func": Callable(self, "_upgrade_adrenaline"), "weight": 10},
	{"name": "Adrenaline Duration +10s", "func": Callable(self, "_upgrade_adrenaline_duration"), "weight": 4},
	{"name": "Phantom Dash", "func": Callable(self, "_upgrade_phantom_dash"), "weight": 4},
]

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				upgrade_1.emit_signal("pressed")
			KEY_2:
				upgrade_2.emit_signal("pressed")
			KEY_3:
				upgrade_3.emit_signal("pressed")


func _ready() -> void:
	visible = false


func show_menu() -> void:
	get_tree().paused = true
	visible = true
	
	current_choices.clear()
	
	var player = get_tree().current_scene.get_node("Jet")
	var available = upgrades.filter(func(u):
		return(
			not used_upgrades.has(u.name)
			and (u.name != "Adrenaline Duration +10s" or player.adrenaline_upgrade_unlocked)
		)
	)
	var weighted_pool = []
	
	for upgrades in available:
		for i in upgrades.weight:
			weighted_pool.append(upgrades)
			
	weighted_pool.shuffle()
	current_choices = weighted_pool.slice(0, 3)
	
	upgrade_1.text = current_choices[0].name
	upgrade_2.text = current_choices[1].name
	upgrade_3.text = current_choices[2].name
	
	
func hide_menu() -> void:
	get_tree().paused = false
	visible = false
	
func _on_Upgrade1_pressed():
	apply_upgrades(current_choices[0].func, current_choices[0].name)
	
func _on_Upgrade2_pressed():
	apply_upgrades(current_choices[1].func, current_choices[1].name)
	
func _on_Upgrade3_pressed():
	apply_upgrades(current_choices[2].func, current_choices[2].name)
	
func apply_upgrades(upgrade_func: Callable, name: String):
	var player = get_tree().current_scene.get_node("Jet")
	upgrade_func.callv([player])
	if name == "Spreadshot" or name == "Piercing Bullets":
		used_upgrades.append(name)
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
	if player.damage_up_count < 3:
		player.base_damage += 1
		player.damage_up_count += 1
	if player.damage_up_count == 3:
		used_upgrades.append("Damage Up")

func _upgrade_piercing(player):
	player.piercing_chance = clamp(player.piercing_chance + 0.2, 0.0, 1.0)
	if player.piercing_chance >= 1.0:
		used_upgrades.append("Piercing Bullets")
	
func _upgrade_target_range(player):
	player.target_range *= 1.1
	
func _upgrade_radial_shot(player):
	player.radial_shot_chance = clamp(player.radial_shot_chance + 0.1, 0.0, 0.4)
	
func _upgrade_max_life(player):
	player.upgrade_max_life()
	
func _upgrade_adrenaline(player):
	player.adrenaline_upgrade_unlocked = true
	player.check_adrenaline()
	used_upgrades.append("Adrenaline Rush at 1HP")
	
func _upgrade_adrenaline_duration(player):
	player.adrenaline_duration += 10
	
func _upgrade_phantom_dash(player):
	player.phantom_dash_active = true
	used_upgrades.append("Phantom Dash")
