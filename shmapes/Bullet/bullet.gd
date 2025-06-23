extends Area2D

@export var speed := 800.0
const ENEMY_CIRCLE = preload("res://enemy_circle/enemy_circle.tscn")

var direction := Vector2.ZERO
const HIT_EFFECT = preload("res://Hit_Effect/hit_effect.tscn")

func _ready():
	pass

func _process(delta):
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ENEMY"):
		if body.has_method("take_damage"):
			body.take_damage(1)
			on_bullet_hit_enemy(body.global_position)
	queue_free()
	
func on_bullet_hit_enemy(_pos):
	var effect = HIT_EFFECT.instantiate()
	effect.global_position = position
	get_tree().current_scene.add_child(effect)
