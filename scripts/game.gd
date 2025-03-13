extends Node2D

@onready var player = $Player
@onready var shop = $Shop
@onready var stats = $Stats
@onready var animation_player = $AnimationPlayer
@onready var spider_scene = preload("res://scenes/spider.tscn")

@export var spawn_points: Array[Vector2] = [Vector2(-45, -95), Vector2(-25, -95), Vector2(45, -95), Vector2(-160, -55), Vector2(-160, 0), Vector2(-145, 90), Vector2(60, 95), Vector2(120, 95), Vector2(160, -40), Vector2(160, 45)]

var wave = 0
var spiders_remaining = 1

func _ready():
	if OS.get_name() == "Android":
		$"Next Wave".position += Vector2(-30, 0)
	else:
		$Android_Controls/Left_Joystick.visible = false
		$Android_Controls/Right_Joystick.visible = false
	start_wave()
	pass

func _process(_delta):
	pass

func start_wave() -> void:
	wave += 1
	stats.update_wave(wave)
	$"Next Wave".visible = false
	shop.disable_shop()
	animation_player.play("fade_in")
	
	if wave == 1:
		spiders_remaining = 1
	elif wave == 2:
		spiders_remaining = 3
	elif wave == 3:
		spiders_remaining = 4
	elif wave == 4:
		spiders_remaining = 5
	elif wave == 5:
		spiders_remaining = 6
	else:
		spiders_remaining = min(25, 6 + (wave - 5))  # Caps at 30 spiders
	
	for _i in spiders_remaining:
		var point = spawn_points[randi_range(0, spawn_points.size()-1)]
		spawn_spider(point)
		$"Spawn_Timer".start(randf_range(2, 5))
		await $"Spawn_Timer".timeout

func spawn_spider(_position: Vector2) -> void:
	var spider = spider_scene.instantiate()
	spider.global_position = _position
	spider.connect("died", _on_spider_died)
	add_child(spider)

func _on_spider_died() -> void:
	spiders_remaining -= 1
	stats.update_score(100)
	if spiders_remaining <= 0:
		animation_player.play("fade_out")
		wave_cleared()

func wave_cleared() -> void:
	stats.save_wave(wave)
	animation_player.play("fade_out")
	stats.update_score(500)
	$"Shop".items["Shield Of Fire"]["purchased"] = false
	if wave % 2 == 0:
		shop.enable_shop()
	else:
		if not $"Next Wave".visible:
			$"Next Wave".visible = true
			for i in range(9, -1, -1):
				if not $"Next Wave".visible:
					return
				$"Next Wave/Button".text = ":" + str(i)
				$"Next Wave/Timer".start()
				await $"Next Wave/Timer".timeout
			$"Next Wave".visible = false
			start_wave()

func _on_player_died() -> void:
	get_tree().paused = true
	$"You_Died".visible = true
