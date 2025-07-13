extends CharacterBody2D

@onready var game_ui = get_node("/root/Game/GameUI")
@export var base_speed := 50.0
@export var max_health: int = 2
@onready var explosion: GPUParticles2D = $explosion
@onready var circle: Sprite2D = $Circle
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var die_sound: AudioStreamPlayer2D = $die_sound

const HEART_PICKUP = preload("res://Pickable/heart_pickup.tscn")
const NUKE_PICKUP = preload("res://NukePickup/nuke_pickup.tscn")

var speed = base_speed
var max_speed = 150.0

var player: Node2D
var health := max_health
var knockback_timer: float = 0.0

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
	ui.add_score(10)
	explosion.emitting = true
	
	var heal_chance := randf()
	if heal_chance <= 0.01:
		call_deferred("spawn_heart")
	
	await get_tree().create_timer(0.8).timeout
	
	drop_nuke_pickup()
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
	
	if knockback_timer > 0.0:
		move_and_slide()
		knockback_timer -= delta
	else:
		velocity = Vector2.ZERO
	
	

func flash_on_hit():
	modulate = Color(1, 0.4,0.4)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
	
func spawn_heart() -> void:
	var heal = HEART_PICKUP.instantiate()
	heal.global_position = position
	get_tree().current_scene.add_child(heal)

func drop_nuke_pickup():
	if randf() < 0.001:
		var nuke = NUKE_PICKUP.instantiate()
		nuke.global_position = global_position
		get_tree().current_scene.add_child(nuke)
		
		
func apply_knockback(force: Vector2) -> void:
	velocity += force
	knockback_timer = 0.2
	
	
	
	
	
	
	
