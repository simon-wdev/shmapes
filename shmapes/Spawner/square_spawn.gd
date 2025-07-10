extends Node2D

const ENEMY_SQUARE = preload("res://enemy_square/enemy_square.tscn")

@onready var spawn_time: Timer = $spawn_time

var current_square_health := 5


func _ready() -> void:
	start_square_spawn_timer()


func spawn_square() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var enemy = ENEMY_SQUARE.instantiate()
	var margin = 100
	var spawn_pos = Vector2(
		randf_range(margin, screen_size.x - margin),
		randf_range(margin, screen_size.y - margin)
		)
		
	enemy.global_position = spawn_pos
	enemy.max_health = current_square_health
	enemy.health = current_square_health
	get_tree().current_scene.add_child(enemy)

func start_square_spawn_timer() -> void:
	var random_time = randf_range(30.0, 60.0)
	spawn_time.wait_time = random_time
	current_square_health += 1
	spawn_time.start()
	
	
func _on_spawn_time_timeout() -> void:
	spawn_square()
	start_square_spawn_timer()
