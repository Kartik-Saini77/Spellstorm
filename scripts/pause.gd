extends Control

var game_paused = false

func _ready() -> void:
	$".".visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Esc"):
		toggle_pause()

func _on_resume_pressed() -> void:
	game_paused = false
	get_tree().paused = false
	$".".visible = false

func _on_main_menu_pressed():
	game_paused = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func toggle_pause() -> void:
	game_paused = !game_paused
	get_tree().paused = game_paused
	$".".visible = game_paused
