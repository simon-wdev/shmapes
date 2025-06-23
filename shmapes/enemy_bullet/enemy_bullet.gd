extends Area2D

@export var speed = 150
var direction = Vector2.RIGHT
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
