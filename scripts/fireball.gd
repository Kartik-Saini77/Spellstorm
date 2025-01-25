extends Node2D

@export var speed: float = 300.0
var direction = Vector2.ZERO
var camera = Vector2(960, 540)/5

func _process(delta: float) -> void:
	position += direction * speed * delta

	if not (abs(global_position).x<camera.x and abs(global_position.y)<camera.y):
		queue_free()

func set_direction(dir: Vector2):
	direction = dir.normalized()
	rotation = direction.angle()
