extends Node2D

const CIRCLE_TANK = preload("res://enemy_circle/circle_tank.tscn")
@onready var spawn_interval: Timer = $spawn_interval
@onready var spawn_increase: Timer = $spawn_increase

func spawn_tank() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var spawn_pos: Vector2
	var side = randi() % 4
	
	match side:
		0: spawn_pos = Vector2(randf_range(0, screen_size.x), -50)
		1: spawn_pos = Vector2(randf_range(0,screen_size.x), screen_size.y + 50)
		2: spawn_pos = Vector2(-50, randf_range(0, screen_size.y))
		3: spawn_pos = Vector2(screen_size.x + 50, randf_range(0, screen_size.y))
	
	var enemy = CIRCLE_TANK.instantiate()
	enemy.global_position = spawn_pos
	get_tree().current_scene.add_child(enemy)



func _on_spawn_start_timeout() -> void:
	start_spawning()
	
func _on_spawn_increase_timeout() -> void:
	spawn_interval.wait_time = max(spawn_interval.wait_time - 1.0, 5.0)

func start_spawning() -> void:
	_on_spawn_increase_timeout()
	spawn_tank()
	spawn_interval.start()
	spawn_increase.start()
	
func _on_spawn_interval_timeout() -> void:
	_on_spawn_increase_timeout()
	spawn_tank()
