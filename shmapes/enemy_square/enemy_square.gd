extends CharacterBody2D

@export var max_health: int = 5
@onready var square: Sprite2D = $RotationNode/Square
@onready var explosion: GPUParticles2D = $explosion
@onready var die_sound: AudioStreamPlayer2D = $die_sound

const ENEMY_BULLET = preload("res://enemy_bullet/enemy_bullet.tscn")
const HEART_PICKUP = preload("res://Pickable/heart_pickup.tscn")

var is_active = false
var screen_size
var target_pos
var shoot_timer = 0.0
var base_shoot_interval = 1.0
var min_shoot_interval = 0.3
var shoot_interval = base_shoot_interval
var health := max_health
var is_dying = false

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if is_dying:
		return
		
	if is_active:
		$RotationNode.rotation += 0.4 * delta
		
		var game_ui = get_tree().current_scene.get_node("GameUI")
		var current_score = game_ui.score
		
		shoot_interval = base_shoot_interval - (current_score * 0.0004)
		shoot_interval = max(shoot_interval, min_shoot_interval)
	
		shoot_timer += delta
		if shoot_timer > shoot_interval:
			shoot_timer = 0.0
			shoot()


func shoot():
	var spawners = [
		$RotationNode/bullet_spawner1,
		$RotationNode/bullet_spawner2,
		$RotationNode/bullet_spawner3,
		$RotationNode/bullet_spawner4
	]
	
	for spawn in spawners:
		var bullet = ENEMY_BULLET.instantiate()
		bullet.global_position = spawn.global_position
		bullet.direction = spawn.global_transform.x.normalized()
		get_tree().current_scene.add_child(bullet)


func _on_spawn_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade-in":
		is_active = true
		
func take_damage(amount: int) -> void:
	health -= amount
	flash_on_hit()
	if health <= 0:
		die()
		
func die() -> void:
	is_dying = true
	remove_from_group("ENEMY")
	$CollisionShape2D.set_deferred("disabled", true)
	square.hide()
	die_sound.play()
	var ui = get_tree().current_scene.get_node("GameUI")
	ui.add_score(30)
	explosion.emitting = true
	
	var heal_chance := randf()
	if heal_chance <= 0.02:
		call_deferred("spawn_heart")
	
	await get_tree().create_timer(0.9).timeout
	
	queue_free()
	
func flash_on_hit():
	modulate = Color(1, 0.4,0.4)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

func spawn_heart() -> void:
	var heal = HEART_PICKUP.instantiate()
	heal.global_position = position
	get_tree().current_scene.add_child(heal)
