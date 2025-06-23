extends CharacterBody2D

@export var speed = 100
@export var shoot_interval = 0.5

const ENEMY_BULLET = preload("res://enemy_bullet/enemy_bullet.tscn")

@onready var bullet_spawner_1: Marker2D = $bullet_spawner1
@onready var bullet_spawner_2: Marker2D = $bullet_spawner2
@onready var bullet_spawner_3: Marker2D = $bullet_spawner3
@onready var bullet_spawner_4: Marker2D = $bullet_spawner4



var is_active = false
var screen_size
var target_pos
var is_stationary = false
var shoot_timer = 0.0

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if is_active:
		$RotationNode.rotation += 0.7 * delta
	
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
