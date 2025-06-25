extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


func show_menu() -> void:
	get_tree().paused = true
	visible = true
	
func hide_menu() -> void:
	get_tree().paused = false
	visible = false
	
func _on_Upgrade1_pressed():
	print("CLICK")
	var player = get_tree().current_scene.get_node("Jet")
	player.fire_rate *= 0.9
	hide_menu()
	
func _on_Upgrade2_pressed():
	var player = get_tree().current_scene.get_node("Jet")
	player.speed *= 1.1
	hide_menu()
	
func _on_Upgrade3_pressed():
	var player = get_tree().current_scene.get_node("Jet")
	player.dash_cooldown.wait_time *= 0.9
	hide_menu()
