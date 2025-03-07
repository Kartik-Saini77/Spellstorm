extends Control

@onready var play_button = $Play/Button
@onready var exit_button = $Exit/Button
@onready var animation_player = $AnimationPlayer

func _ready():
	pass

func _on_play_pressed():
	animation_player.play("move_up")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_exit_pressed():
	get_tree().quit()
