extends CharacterBody2D

@export var health: int = 50
@export var melee_damage: int = 20
@export var speed: float = 50.0
@export var attack_cooldown: float = 2.0
@export var random_movement_interval: float = 1.5
@export var melee_cooldown: float = 3.0
@export var min_distance_from_player: float = 20.0
@export var push_force: float = 70.0
@export var push_duration: float = 0.2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $Attack_Timer
@onready var random_timer: Timer = $Random_Timer
@onready var melee_timer: Timer = $Melee_Timer
@onready var push_timer: Timer = $Push_Timer
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")

signal died

var is_attacking: bool = false
var move_velocity: Vector2 = Vector2.ZERO
var is_dead: bool = false
var is_pushing: bool = false
var target_position: Vector2 = Vector2.ZERO

const DROP_ITEMS = [
	{ "scene": preload("res://scenes/fireball_drop.tscn"), "chance": 0.3 },
	{ "scene": preload("res://scenes/shield_of_fire.tscn"), "chance": 0.1 },
	{ "scene": preload("res://scenes/coin.tscn"), "chance": 0.6 }
]

func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	var distance_to_player = global_position.distance_to(player.global_position)

	if distance_to_player < min_distance_from_player and not is_pushing:
		start_push_movement()

	if not is_pushing:
		target_position = player.global_position

	if not is_attacking:
		move_velocity = (target_position - global_position).normalized() * speed
	else:
		move_velocity = Vector2.ZERO

	velocity = move_velocity
	move_and_slide()

	if is_pushing:
		sprite.play("walk")
	elif is_attacking:
		sprite.play("idle")
	elif velocity == Vector2.ZERO:
		sprite.play("idle")
	else:
		sprite.play("walk")
	
	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0

func start_push_movement() -> void:
	is_pushing = true
	target_position = global_position + (global_position - player.global_position).normalized() * push_force
	push_timer.start(push_duration)

func _on_push_timer_timeout() -> void:
	is_pushing = false
	attack_timer.start(attack_cooldown)

func _on_random_timer_timeout() -> void:
	if is_dead or is_pushing:
		return

	var random_dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	target_position = (global_position + random_dir * 70)
	random_timer.start(random_movement_interval)

func _on_attack_timer_timeout() -> void:
	if is_dead:
		return

	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player >= 100:
		perform_web_attack()
	attack_timer.start(attack_cooldown)

func _on_area_2d_body_entered(body: Node) -> void:
	if is_dead or is_pushing:
		return

	if body == player and not is_attacking:
		perform_melee_attack()

func perform_melee_attack() -> void:
	is_attacking = true

	var orig_pos = global_position
	var attack_target = player.global_position
	var attack_duration = 0.3
	var elapsed = 0.0

	sprite.play("jump")
	while elapsed < attack_duration:
		if is_dead:
			return
		global_position = orig_pos.lerp(attack_target, elapsed / attack_duration)
		await get_tree().process_frame
		elapsed += get_process_delta_time()

	if is_dead:
		return

	if global_position.distance_to(player.global_position) < 20:
		player.damage(melee_damage)
	sprite.play("idle")
	is_attacking = false
	melee_timer.start(melee_cooldown)
	

func _on_Melee_Timer_timeout() -> void:
	is_attacking = false

func perform_web_attack() -> void:
	if is_dead:
		return

	var web_instance = preload("res://scenes/web_projectile.tscn").instantiate()
	web_instance.global_position = global_position + Vector2(0, 3)
	get_tree().current_scene.add_child(web_instance)
	web_instance.set_direction(player.global_position)

func damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount
	anim_player.play("damage")

	if health <= 0:
		die()

func die() -> void:
	if is_dead:
		return

	is_dead = true
	move_velocity = Vector2.ZERO
	attack_timer.stop()
	random_timer.stop()
	melee_timer.stop()
	is_attacking = false

	$CollisionShape2D.set_deferred("disabled", true)
	sprite.play("upside_down")
	await sprite.animation_finished
	drop_loot()
	$"../Stats".update_score(100)
	died.emit()
	queue_free()

func drop_loot() -> void:
	var roll = randf_range(0.0, 2.0)
	
	var cumulative_chance = 0.0
	for item in DROP_ITEMS:
		cumulative_chance += item["chance"]
		if roll <= cumulative_chance:
			var drop_instance = item["scene"].instantiate()
			drop_instance.global_position = global_position
			get_tree().current_scene.add_child(drop_instance)
			break
