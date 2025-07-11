extends Node2D

const ENEMY_CIRCLE = preload("res://enemy_circle/enemy_circle.tscn")
@onready var spawn_interval: Timer = $spawn_interval




func spawn_circle() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var spawn_pos: Vector2
	var side = randi() % 4
	
	match side:
		0: spawn_pos = Vector2(randf_range(0, screen_size.x), -50)
		1: spawn_pos = Vector2(randf_range(0,screen_size.x), screen_size.y + 50)
		2: spawn_pos = Vector2(-50, randf_range(0, screen_size.y))
		3: spawn_pos = Vector2(screen_size.x + 50, randf_range(0, screen_size.y))
	
	var enemy = ENEMY_CIRCLE.instantiate()
	enemy.global_position = spawn_pos
	get_tree().current_scene.add_child(enemy)


func _on_spawn_interval_timeout() -> void:
	spawn_circle()
	


func _on_spawn_increase_timeout() -> void:
	spawn_interval.wait_time = max(spawn_interval.wait_time - 0.05, 0.07)
