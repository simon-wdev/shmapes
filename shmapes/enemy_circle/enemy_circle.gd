extends CharacterBody2D

@onready var game_ui = get_node("/root/Game/GameUI")
@export var speed := 100.0
@export var max_health: int = 2
@onready var explosion: GPUParticles2D = $explosion
@onready var circle: Sprite2D = $Circle
@export var rotation_speed := 80.0

var player: Node2D
var health := max_health

func take_damage(amount: int) -> void:
	health -= 1
	flash_on_hit()
	if health <= 0:
		die()
		
func die() -> void:
	circle.hide()
	explosion.emitting = true
	collision_layer = false
	await get_tree().create_timer(0.5).timeout
	Score.score += 10
	var ui = get_tree().current_scene.get_node("GameUI")
	ui.update_score_points(Score.score)
	queue_free()
	


func _ready() -> void:
	var players = get_tree().get_nodes_in_group("PLAYER")
	if not players.is_empty():
		player = players[0]

func _process(delta: float) -> void:
	if player == null:
		return

	var direction = (player.global_position - global_position).normalized()
	global_position += direction * speed * delta
	
	rotation_degrees += rotation_speed * delta

func flash_on_hit():
	modulate = Color(1, 0.4,0.4)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
	
	
	
	
	
	
	
	
	
	
