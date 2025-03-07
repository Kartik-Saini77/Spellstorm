extends Node2D

@onready var player = $Player
@onready var shop = $Shop
@onready var stats = $Stats
@onready var animation_player = $AnimationPlayer
@onready var spider_scene = preload("res://scenes/spider.tscn")

@export var spawn_points: Array[Vector2] = [Vector2(-35, -80)]

var wave = 1
var spiders_remaining = 1

func _ready():
	start_wave()

func _process(_delta):
	pass

func start_wave() -> void:
	$"Next Wave".visible = false
	shop.disable_shop()
	animation_player.play("fade_in")
	spiders_remaining = wave * 2 - 1									#TODO
	print(spiders_remaining)
	for _i in spiders_remaining:
		var point = spawn_points[randi_range(0, spawn_points.size()-1)]
		spawn_spider(point)
		await get_tree().create_timer(randf_range(2, 5)).timeout
		print(point)

func spawn_spider(position: Vector2) -> void:
	var spider = spider_scene.instantiate()
	spider.global_position = position
	spider.connect("died", _on_spider_died)
	add_child(spider)

func _on_spider_died() -> void:
	spiders_remaining -= 1
	stats.update_score(100)
	if spiders_remaining <= 0:
		animation_player.play("fade_out")
		wave_cleared()

func wave_cleared() -> void:
	animation_player.play("fade_out")
	stats.update_score(500)
	wave += 1
	if wave % 2 == 1:
		shop.enable_shop()
		pass
	else:
		$"Next Wave".visible = true
		for i in range(9, -1, -1):
			$"Next Wave/Button".text = ":" + str(i)
			await get_tree().create_timer(1.0).timeout
		if $"Next Wave".visible:
			$"Next Wave".visible = false
			start_wave()

func _on_player_died() -> void:
	get_tree().paused = true
	$"You_Died".visible = true
