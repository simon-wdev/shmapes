extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var heal_sound: AudioStreamPlayer2D = $HealSound
@onready var sprite_2d: Sprite2D = $Sprite2D





func _ready() -> void:
	animation_player.play()
	
	await get_tree().create_timer(5).timeout
	var tween = create_tween()
	tween.tween_property(animation_player, "speed_scale", 4.0, 15.0)
	
	await get_tree().create_timer(10).timeout
	queue_free()
	
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER") and body.current_health < body.max_health:
		body.heal_player()
		heal_sound.play()
		sprite_2d.hide()
		await get_tree().create_timer(0.3).timeout
		queue_free()
