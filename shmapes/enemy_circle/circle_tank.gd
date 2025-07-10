extends CharacterBody2D

@onready var game_ui = get_node("/root/Game/GameUI")
@export var speed := 100.0
@export var max_health: int = 10
@onready var explosion: GPUParticles2D = $explosion
@onready var circle: Sprite2D = $Circle
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var die_sound: AudioStreamPlayer2D = $die_sound

const HEART_PICKUP = preload("res://Pickable/heart_pickup.tscn")

var player: Node2D
var health := max_health

func take_damage(amount: int) -> void:
	health -= amount
	flash_on_hit()
	if health <= 0:
		die()
		
func die() -> void:
	remove_from_group("ENEMY")
	$CollisionShape2D.set_deferred("disabled", true)
	circle.hide()
	die_sound.play()
	var ui = get_tree().current_scene.get_node("GameUI")
	ui.add_score(50)
	explosion.emitting = true
	
	var heal_chance := randf()
	if heal_chance <= 0.02:
		call_deferred("spawn_heart")
	
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
	
	get_tree().current_scene.get_node("GameUI")
	var current_score = game_ui.score
	
	rotation += deg_to_rad(60) * delta

func flash_on_hit():
	modulate = Color(1, 0.4,0.4)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
	
func spawn_heart() -> void:
	var heal = HEART_PICKUP.instantiate()
	heal.global_position = position
	get_tree().current_scene.add_child(heal)
	
	
	
