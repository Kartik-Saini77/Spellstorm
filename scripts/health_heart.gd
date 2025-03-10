extends Node2D

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")

func _ready():
	pass

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player.add_to_inventory("heart")
		queue_free()
