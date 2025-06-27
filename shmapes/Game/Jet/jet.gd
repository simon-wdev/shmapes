extends CharacterBody2D

@export var speed := 350.0
@export var fire_rate := 0.3
@export var dash_speed := 1500
@export var target_range := 500.0

const BULLET = preload("res://Bullet/bullet.tscn")

@onready var marker_2d: Marker2D = $Marker2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var invul_timer: Timer = $invul_timer
@onready var dash_cooldown: Timer = $dash_cooldown
@onready var dash_duration_timer: Timer = $dash_duration_timer
@onready var dash_cam: Camera2D = $DashCam
@onready var game_ui: CanvasLayer = $"../GameUI"

var current_target: Node2D = null
var max_health = 3
var current_health = max_health
var time_since_last_shot := 0.0
var is_invulnerable = false
var is_dashing = false
var dash_direction = Vector2.ZERO

func _ready() -> void:
	current_health = max_health
	if game_ui:
		game_ui.update_hearts(current_health)
	

func _process(delta: float) -> void:
	var new_target = get_nearest_visible_enemy()

	if new_target != current_target:
		current_target = new_target
		time_since_last_shot = 0.0

	if current_target:
		var target_angle = (current_target.global_position - global_position).angle()
		rotation = lerp_angle(rotation, target_angle, delta * 10)
	else:
		var input_vector = Vector2.ZERO
		if Input.is_action_pressed("UP"):
			input_vector.y -= 1
		if Input.is_action_pressed("DOWN"):
			input_vector.y += 1
		if Input.is_action_pressed("LEFT"):
			input_vector.x -= 1
		if Input.is_action_pressed("RIGHT"):
			input_vector.x += 1
			
		if input_vector.length() > 0:
			var input_angle = input_vector.angle()
			rotation = lerp_angle(rotation, input_angle, delta * 5.0)
			
		else:
			rotation = lerp_angle(rotation, -PI / 2, delta * 2.0)

	time_since_last_shot += delta

	if current_target and time_since_last_shot >= fire_rate:
		shoot()
		time_since_last_shot = 0.0

func shoot():
	var target = get_nearest_visible_enemy()
	if not target:
		return
	var bullet = BULLET.instantiate()
	bullet.global_position = marker_2d.global_position
	bullet.direction = (target.global_position - global_position).normalized()
	get_tree().current_scene.add_child(bullet)

func _physics_process(_delta: float) -> void:
	var input_vector := Vector2.ZERO

	if Input.is_action_pressed("UP"):
		input_vector.y -= 1
	if Input.is_action_pressed("DOWN"):
		input_vector.y += 1
	if Input.is_action_pressed("LEFT"):
		input_vector.x -= 1
	if Input.is_action_pressed("RIGHT"):
		input_vector.x += 1

	if is_dashing:
		velocity = dash_direction * dash_speed
	else:
		velocity = velocity.lerp(input_vector.normalized() * speed, 0.3)
		
	dash()
	
	move_and_slide()
	
	var screen_size = get_viewport().get_visible_rect().size
	
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
	
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	
func player_take_damage(amount: int = 1):
	if is_invulnerable:
		return
	current_health -= amount
	get_tree().current_scene.get_node("GameUI").update_hearts(current_health)
	is_invulnerable = true
	animation_player.play("invuln_animation")
	invul_timer.start()
	
	if current_health <= 0:
		die()

func die() -> void:
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("ENEMY"):
		player_take_damage()


func _on_invul_timer_timeout() -> void:
	is_invulnerable = false

func dash() -> void:
	if Input.is_action_just_pressed("dash") and not is_dashing and not dash_cooldown.is_stopped():
		return
	
	
	if Input.is_action_just_pressed("dash") and not is_dashing:
		is_dashing = true
		is_invulnerable = true
		dash_direction = get_dash_direction().normalized()
		dash_duration_timer.start()
		dash_cooldown.start()

func get_dash_direction() -> Vector2:
	var input_vector := Vector2.ZERO
	
	if Input.is_action_pressed("UP"):
		input_vector.y -= 1
	if Input.is_action_pressed("DOWN"):
		input_vector.y += 1
	if Input.is_action_pressed("LEFT"):
		input_vector.x -= 1
	if Input.is_action_pressed("RIGHT"):
		input_vector.x += 1
		
	return input_vector


func _on_dash_cooldown_timeout() -> void:
	is_dashing = false
	is_invulnerable = false


func _on_dash_duration_timer_timeout() -> void:
	is_dashing = false
	is_invulnerable = false
	


func get_nearest_visible_enemy() -> Node2D:
	var closest_enemy: Node2D = null
	var closest_dist := INF
	
	for enemy in get_tree().get_nodes_in_group("ENEMY"):
		if not enemy.is_inside_tree(): continue
		if not enemy.visible: continue
		if "is_active" in enemy and not enemy.is_active: continue
		
		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_dist and dist <= target_range:
			closest_dist = dist
			closest_enemy = enemy
			
	return closest_enemy
	
	
func heal_player() -> void:
	if current_health == max_health:
		return

	if current_health <= max_health:
		current_health += 1
		game_ui.update_hearts(current_health)
