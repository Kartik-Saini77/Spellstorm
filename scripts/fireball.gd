extends Node2D

@export var speed: float = 300.0
@export var damage: float = 30	#this value doesn't matter, check 'dmg' in player

var direction: Vector2 = Vector2.ZERO
var camera_limit: Vector2 = Vector2(960, 540) / 5

func _ready() -> void:
	add_to_group("Fireball")

func _process(delta: float) -> void:
	position += direction * speed * delta
	
	if not (abs(global_position.x) < camera_limit.x and abs(global_position.y) < camera_limit.y):
		queue_free()

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func _on_area_entered(area: Area2D) -> void:
	var body = area.get_parent()

	if body.is_in_group("WebProjectile"):
		$"../Stats".update_score(1)
		body.queue_free()
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Spider"):
		if not body.is_dead:
			var rnd = randf_range(-3, 1)
			body.damage(damage + rnd)
			queue_free()
