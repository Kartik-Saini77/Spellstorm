extends Node2D

enum ShieldState { DROPPED, EQUIPPED }
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state = ShieldState.DROPPED
@onready var player: Node2D = get_tree().get_first_node_in_group("Player")

func _ready():
	$Area2D/CollisionShape2D.shape.radius = 18.0
	update_animation()

func _process(_delta: float) -> void:
	if state == ShieldState.EQUIPPED:
		global_position = player.global_position

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		if player.equipped_shield:
			player.equipped_shield.queue_free()
		
		$Area2D/CollisionShape2D.shape.radius = 24.0
		state = ShieldState.EQUIPPED
		player.equipped_shield = self
		player.add_to_inventory("shield")
		update_animation()

func reduce_durability():
	if player.inventory["shield"]:
		player.inventory["shield"] -= 1
		sprite.play("explosion")
		await $AnimatedSprite2D.animation_finished
		update_animation()

	if player.inventory["shield"] == 0:
		player.equipped_shield = null
		queue_free()

func update_animation():
	if state == ShieldState.DROPPED:
		sprite.play("idle")
	else:
		match player.inventory["shield"]:
			1: sprite.play("shield_1")
			2: sprite.play("shield_2")
			_: sprite.play("shield_3")
