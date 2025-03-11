extends Control

@onready var play_button: Button = $Play/Button
@onready var exit_button: Button = $Exit/Button
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var high_score_label: Label = $"Stats/HighScore"
@onready var wave_label: Label = $"Stats/MaxWave"

var wave: int = 0
var high_score: int = 0

const SAVE_PATH: String = "user://high_score.save"

func _ready():
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
	animation_player.play("move_up")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_exit_pressed():
	get_tree().quit()
