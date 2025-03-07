extends Control

func _ready() -> void:
	$".".visible = false

func _process(delta: float) -> void:
	pass

func _on_play_again_pressed() -> void:
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
