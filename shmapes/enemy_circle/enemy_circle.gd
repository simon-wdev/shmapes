extends CharacterBody2D

@onready var game_ui = get_node("/root/Game/GameUI")
@export var base_speed := 100.0
@export var max_health: int = 2
@onready var explosion: GPUParticles2D = $explosion
@onready var circle: Sprite2D = $Circle
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var die_sound: AudioStreamPlayer2D = $die_sound

var speed = base_speed
var max_speed = 400.0

var player: Node2D
var health := max_health

func take_damage(_amount: int) -> void:
	health -= 1
	flash_on_hit()
	if health <= 0:
		die()
		
func die() -> void:
	remove_from_group("ENEMY")
	$CollisionShape2D.set_deferred("disabled", true)
	circle.hide()
	die_sound.play()
	var ui = get_tree().current_scene.get_node("GameUI")
	ui.add_score(10)
	explosion.emitting = true
	await get_tree().create_timer(0.8).timeout
	
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
	
	var game_ui = get_tree().current_scene.get_node("GameUI")
	var current_score = game_ui.score
	speed = base_speed + (current_score * 0.1)
	speed = min(speed, max_speed)
	
	

func flash_on_hit():
	modulate = Color(1, 0.4,0.4)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
	
	
	
	
	
	
	
	
	
	
