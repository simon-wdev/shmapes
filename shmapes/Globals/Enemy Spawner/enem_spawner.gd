extends Node

const ENEMY_SQUARE = preload("res://enemy_square/enemy_square.tscn")
const ENEMY_CIRCLE = preload("res://enemy_circle/enemy_circle.tscn")

@export var spawn_interval := 4.0
@export var spawn_timer_decrease := 0.3
@export var min_spawn_interval := 0.4
@export var difficulty_interval := 10.0
@export var spawn_decrease_step := 0.1

var spawn_timer := 0.0
var difficulty_timer := 0.0
var is_spawning_enabled := true

func _process(delta: float) -> void:
	spawn_timer += delta
	difficulty_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_enemy()
	
	if not is_spawning_enabled:
		return
	
	if difficulty_timer >= difficulty_interval:
		difficulty_timer = 0.0
		spawn_interval = max(spawn_interval - spawn_decrease_step, min_spawn_interval)
	
func spawn_enemy():
	var screen_size = get_viewport().get_visible_rect().size
	var enemy_roll = randf()
	
	if enemy_roll < 0.8:
		var enemy = ENEMY_CIRCLE.instantiate()
		var spawn_pos = Vector2.ZERO
		var side = randi() % 2
	
		match side:
			0: spawn_pos = Vector2(randf_range(0, screen_size.x), -50)
			1: spawn_pos = Vector2(randf_range(0,screen_size.x), screen_size.y + 50)
			2: spawn_pos = Vector2(-50, randf_range(0, screen_size.y))
			3: spawn_pos = Vector2(screen_size.x + 50, randf_range(0, screen_size.y))
	
		enemy.global_position = spawn_pos
		get_tree().current_scene.add_child(enemy)
		
	else:
		var enemy = ENEMY_SQUARE.instantiate()
		
		var margin = 100
		var spawn_pos = Vector2(
			randf_range(margin, screen_size.x-margin),
			randf_range(margin, screen_size.y-margin)
		)
		
		enemy.global_position = spawn_pos
		get_tree().current_scene.add_child(enemy)
