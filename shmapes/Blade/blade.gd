extends Area2D

@export var radius := 100.0
@export var speed := 4.0
@export var damage: int = 5

var angle_offset := 0.0
var center_node : Node2D = null


func _process(delta: float) -> void:
	if center_node:
		var angle = angle_offset + speed * Time.get_ticks_msec() / 1000.0
		global_position = center_node.global_position + Vector2.RIGHT.rotated(angle) * radius
		rotation += deg_to_rad(360) * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ENEMY"):
			body.take_damage(damage)
			
			
			if body.has_method("apply_knockback"):
				var knockback_vector = (body.global_position - global_position).normalized() * 400
				body.apply_knockback(knockback_vector)
