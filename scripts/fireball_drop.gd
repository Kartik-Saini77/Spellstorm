extends Node2D

@export var duration: float = 4.8
@export var intensity: float = 2.0

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")

func _ready():
	$AnimatedSprite2D.play("fireball_idle")

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player.add_to_inventory("fireball")
		$AnimatedSprite2D.hide()
		player.fireball_cooldown /= intensity
		player.fireball_cooldown = max(player.fireball_cooldown, 0.2)
		$Timer.start(duration)

func _on_timer_timeout() -> void:
	player.inventory["fireball"] = false
	player.fireball_cooldown *= intensity
	player.fireball_cooldown = min(player.fireball_cooldown, 0.8)
	queue_free()
