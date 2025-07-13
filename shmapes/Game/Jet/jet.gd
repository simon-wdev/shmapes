extends CharacterBody2D

@export var speed := 350.0
@export var fire_rate := 0.4
@export var dash_speed := 1500
@export var target_range := 500.0

const BULLET = preload("res://Bullet/bullet.tscn")
const BLADE = preload("res://Blade/blade.tscn")
const MAX_BLADES := 6

@onready var jet_sprite: Sprite2D = $Jet1

@export var normal_texture: Texture2D
@export var phantom_texture: Texture2D

@onready var phantom_sound: AudioStreamPlayer2D = $phantom_sound
@onready var phantom_particles: GPUParticles2D = $phantom_particles
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var music = get_tree().current_scene.get_node("AudioStreamPlayer2D")
@onready var adrenaline: AnimationPlayer = $adrenaline
@onready var adrenaline_timer: Timer = $AdrenalineTimer
@onready var marker_2d: Marker2D = $Marker2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var invul_timer: Timer = $invul_timer
@onready var dash_cooldown: Timer = $dash_cooldown
@onready var dash_duration_timer: Timer = $dash_duration_timer
@onready var dash_cam: Camera2D = $DashCam
@onready var game_ui: CanvasLayer = $"../GameUI"
@onready var radial_sfx: AudioStreamPlayer2D = $radial_sfx
@onready var take_damage_sfx: AudioStreamPlayer2D = $take_damage_sfx
@onready var hitbox: Area2D = $Hitbox


var current_target: Node2D = null
var max_health = 3
var current_health = 3
var time_since_last_shot := 0.0
var is_invulnerable = false
var is_dashing = false
var dash_direction = Vector2.ZERO
var has_spreadshot = false
var bullet_scale = 0.08
var crit_chance = 0.0
var base_damage := 1
var damage_up_count := 0
var piercing_chance := 0.0
var radial_shot_chance := 0.0
var adrenaline_active := false
var adrenaline_upgrade_unlocked := false
var adrenaline_duration := 15
var phantom_dash_active := false
var orbiting_blades = []
var blade_damage := 5
var blade_count := 1
var orbiting_blades_active = false
var normal_hitbox_scale := Vector2.ONE
var dash_hitbox_scale := Vector2(2.5, 2.5)

func _ready() -> void:
	current_health = max_health
	if game_ui:
		game_ui.update_hearts(current_health, max_health)
	

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

func enable_spreadshot() -> void:
	has_spreadshot = true


func shoot():
	var target = get_nearest_visible_enemy()
	if not target:
		return
		
	var base_direction = (target.global_position - global_position).normalized()
	
	if has_spreadshot:
		shoot_bullet(base_direction.rotated(deg_to_rad(-5)))
		shoot_bullet(base_direction)
		shoot_bullet(base_direction.rotated(deg_to_rad(5)))
	else:
		shoot_bullet(base_direction)
		
	if randf() < radial_shot_chance:
		var clone_count = 8
		for i in range(clone_count):
			var angle = TAU * i / clone_count
			var dir = Vector2.RIGHT.rotated(angle)
			shoot_colored_bullet(dir, Color(10, 0, 0))
			radial_sfx.play()
		
func shoot_bullet(direction: Vector2) -> void:
	var bullet = BULLET.instantiate()
	bullet.global_position = marker_2d.global_position
	bullet.direction = direction
	bullet.bullet_scale = bullet_scale
	bullet.crit_chance = crit_chance
	bullet.base_damage = base_damage
	bullet.piercing_chance = piercing_chance
	get_tree().current_scene.add_child(bullet)

func shoot_colored_bullet(direction: Vector2, color: Color) -> void:
	var bullet = BULLET.instantiate()
	bullet.global_position = marker_2d.global_position
	bullet.direction = direction
	bullet.bullet_scale = bullet_scale
	bullet.speed = 500.0
	bullet.crit_chance = crit_chance
	bullet.base_damage = base_damage
	bullet.start_color = color
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
	check_adrenaline()
	get_tree().current_scene.get_node("GameUI").update_hearts(current_health, max_health)
	is_invulnerable = true
	animation_player.play("invuln_animation")
	take_damage_sfx.play()
	invul_timer.start()
	
	if current_health <= 0:
		die()

func die() -> void:
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("ENEMY"):
		if phantom_dash_active and is_dashing:
			body.take_damage(10)
		else:
			player_take_damage()


func _on_invul_timer_timeout() -> void:
	is_invulnerable = false

func dash() -> void:
	if Input.is_action_just_pressed("dash") and not is_dashing and not dash_cooldown.is_stopped() and not is_invulnerable:
		return
	
	
	if Input.is_action_just_pressed("dash") and not is_dashing:
		is_dashing = true
		is_invulnerable = true
		dash_direction = get_dash_direction().normalized()
		dash_duration_timer.start()
		dash_cooldown.start()
		
		if phantom_dash_active:
			gpu_particles_2d.hide()
			hitbox.scale = dash_hitbox_scale
			phantom_particles.emitting = true
			phantom_sound.play()
			jet_sprite.texture = phantom_texture
			jet_sprite.scale = Vector2.ONE * 0.07

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
	
	if phantom_dash_active:
		hitbox.scale = normal_hitbox_scale
		is_dashing = false
		is_invulnerable = false
		jet_sprite.texture = normal_texture
		gpu_particles_2d.show()
		jet_sprite.scale = Vector2.ONE
	


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
		
		game_ui.update_hearts(current_health, max_health)
	check_adrenaline()
	if adrenaline_active and current_health > 1:
		disable_adrenaline()

func upgrade_max_life() -> void:
	max_health += 1
	current_health = max_health
	check_adrenaline()
	get_tree().current_scene.get_node("GameUI").update_hearts(current_health, max_health)
	
func check_adrenaline() -> void:
	if not adrenaline_upgrade_unlocked:
		return
	if adrenaline_active:
		return
		
	if current_health == 1 and not adrenaline_active:
		adrenaline_active = true
		music.pitch_scale = 1.3
		fire_rate *= 0.5
		speed *= 1.5
		adrenaline.play("adrenaline_blink")
		adrenaline_timer.start(adrenaline_duration)
	elif current_health > 1 and adrenaline_active:
		disable_adrenaline()

func disable_adrenaline() -> void:
	if not adrenaline_active:
		return
	adrenaline_active = false
	fire_rate /= 0.5
	speed /= 1.5
	music.pitch_scale = 1.0


func _on_adrenaline_timer_timeout() -> void:
	adrenaline.stop()
	disable_adrenaline()
	
func enable_orbiting_blades(count := 1) -> void:
	for blade in orbiting_blades:
		blade.queue_free()
	orbiting_blades.clear()
	
	for i in range(count):
		var blade = BLADE.instantiate()
		get_tree().current_scene.add_child(blade)
		blade.center_node = self
		blade.angle_offset = TAU * i / count
		blade.damage = blade_damage
		orbiting_blades.append(blade)
