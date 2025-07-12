extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var flash: ColorRect = get_tree().current_scene.get_node("FlashOverlay")
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var nuke_sound: AudioStreamPlayer2D = $nuke_sound


func _ready() -> void:
	animation_player.play()
	
	await get_tree().create_timer(5).timeout
	var tween = create_tween()
	tween.tween_property(animation_player, "speed_scale", 4.0, 15.0)
	
	await get_tree().create_timer(10).timeout
	queue_free()
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Jet":
		sprite_2d.hide()
		await nuke_effect()
		queue_free()
		
func nuke_effect():
	
	var anim_player = flash.get_node("AnimationPlayer")
	anim_player.play("Fade")
	nuke_sound.play()
	for enemy in get_tree().get_nodes_in_group("ENEMY"):
		enemy.die()
	await nuke_sound.finished
