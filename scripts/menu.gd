extends Control

#To make any changes in the menu scene, also make the same changes in the animatioln player

@onready var play_button: Button = $Play/Button
@onready var controls_button: Button = $Control/Button
@onready var exit_button: Button = $Exit/Button
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var controls: Sprite2D = $Controls_Sprite2D
@onready var high_score_label: Label = $"Stats/HighScore"
@onready var wave_label: Label = $"Stats/MaxWave"
@onready var game_scene = preload("res://scenes/game.tscn")

var wave: int = 0
var high_score: int = 0

signal any_button_pressed

const SAVE_PATH: String = "user://high_score.save"

func _ready():
	controls.visible = false
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		high_score = file.get_var()
		wave = file.get_var()
		file.close()
	if high_score > 0:
		high_score_label.text = "High Score:" + str(high_score).pad_zeros(4)
		wave_label.text = "Waves Cleared:" + str(wave).pad_zeros(2)
	else:
		high_score_label.text = ""
		wave_label.text = ""

func _on_play_pressed():
	if high_score == 0:
		controls.visible = true
		await any_button_pressed
		controls.visible = false
	disable_buttons()
	animation_player.play("move_up")
	await animation_player.animation_finished
	if game_scene != null:
		get_tree().change_scene_to_packed(game_scene)

func _on_exit_pressed():
	get_tree().quit()

func _on_controls_pressed() -> void:
	if controls.visible == false:
		controls.visible = true
		disable_buttons()
		await any_button_pressed
		controls.visible = false
		await get_tree().create_timer(0.1).timeout
		enable_buttons()

func _input(event):
	if event.is_pressed():
		any_button_pressed.emit()

func disable_buttons():
	play_button.disabled = true
	controls_button.disabled = true
	exit_button.disabled = true

func enable_buttons():
	play_button.disabled = false
	controls_button.disabled = false
	exit_button.disabled = false
