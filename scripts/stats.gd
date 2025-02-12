extends Control

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var healthbar: TextureProgressBar = $Healthbar/TextureProgressBar
@onready var health_label: Label = $Healthbar/Label
@onready var coin_label: Label = $Coin_Count/Label
@onready var score_label: Label = $Score
@onready var high_score_label: Label = $HighScore
@onready var max_health: float = player.health

var score: int = 0
var high_score: int = 0

func _ready():
	healthbar.value = player.health / max_health * 100.0
	health_label.text = str(player.health) + "/" + str(max_health)
	health_label.visible = false
	score_label.text = "Score:0000"
	high_score_label.text = "High Score:0000"

func _process(_delta: float) -> void:
	pass

func update_health() -> void:
	healthbar.value = player.health / max_health * 100.0
	health_label.text = str(player.health) + "/" + str(max_health)

func _on_healthbar_mouse_entered() -> void:
	health_label.visible = true

func _on_healthbar_mouse_exited() -> void:
	health_label.visible = false

func update_coin(coins: int) -> void:
	coin_label.text = str(coins)
	update_score(10)

func update_score(amount: int) -> void:
	score += amount
	score_label.text = "Score:" + str(score).pad_zeros(4)
	if score > high_score:
		high_score = score
		high_score_label.text = "High Score:" + str(high_score).pad_zeros(4)

func wave_cleared() -> void:
	update_score(500)
