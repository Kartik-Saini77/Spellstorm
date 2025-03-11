extends Node2D

@export var lifespan: float = 1.0
@export var speed: float = 200.0
@export var dmg: float = 20
@export var slow_duration: float = 3.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var lifespan_timer: Timer = $Lifespan
@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
var is_slowness: bool = false
var slow_prob: float = 10  # percentage (0, 100), will change based on curr wave

var direction: Vector2 = Vector2.ZERO

func _ready():
	is_slowness = randi_range(0, 100) <= slow_prob
	if is_slowness:
		$AnimationPlayer.play("slow")
	else:
		$AnimationPlayer.play("RESET")

	lifespan_timer.start(lifespan)
	if direction.x >= 0:
		sprite.play("web_right")
	else:
		sprite.play("web_left")

func _process(delta):
	position += direction * speed * delta

func set_direction(_dir: Vector2):
	direction = (player.global_position - global_position).normalized()

func _on_body_entered(body: Node2D):
	if body.is_in_group("Fireball"):
		queue_free()
		body.queue_free()
	
	var rnd = randf_range(-8, 2)
	if body == player and player.damage(dmg + rnd):
		if is_slowness:
			player.apply_slow(slow_duration)
		queue_free()

func _on_lifespan_timeout():
	queue_free()
