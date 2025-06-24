extends Area2D


const HIT_EFFECT = preload("res://Hit_Effect/hit_effect.tscn")

@export var speed = 150

var direction = Vector2.RIGHT

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		if body.has_method("player_take_damage"):
			body.player_take_damage(1)
			on_bullet_hit_player(body.global_position)
	queue_free()
	
func on_bullet_hit_player(_pos):
	var effect = HIT_EFFECT.instantiate()
	effect.global_position = position
	get_tree().current_scene.add_child(effect)
