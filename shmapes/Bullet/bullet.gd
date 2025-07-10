extends Area2D



const ENEMY_CIRCLE = preload("res://enemy_circle/enemy_circle.tscn")
const HIT_EFFECT = preload("res://Hit_Effect/hit_effect.tscn")


@export var speed := 800.0
@export var base_damage: int = 1
@export var bullet_scale: float = 0.08
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var crit_chance: float = 0.0

var piercing := false
var direction := Vector2.ZERO


func _ready():
	$Sprite2D.scale = Vector2.ONE * bullet_scale
	$CollisionShape2D.scale = Vector2.ONE * bullet_scale

func _process(delta):
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ENEMY"):
		var is_crit = randf() < crit_chance
		var damage = base_damage
		if is_crit:
			damage *= 2
		body.take_damage(damage)
		
		on_bullet_hit_enemy(body.global_position)
		
		if is_crit:
			show_crit_feedback()
	if not piercing:
		queue_free()
	
func on_bullet_hit_enemy(_pos):
	var effect = HIT_EFFECT.instantiate()
	effect.global_position = position
	get_tree().current_scene.add_child(effect)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	
func show_crit_feedback():
	modulate = Color (1, 1, 0.2)
	await get_tree().create_timer(0.1).timeout
	modulate = Color (1, 1, 1)
