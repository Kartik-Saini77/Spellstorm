extends CharacterBody2D

@export var speed = 100.0
@export var health: float = 100.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var screen_size: Vector2 = get_viewport_rect().size
@onready var fireball_scene = preload("res://scenes/fireball.tscn")
@onready var slow_timer: Timer = $Slow_Timer
@onready var invin_timer: Timer = $Invincibility
@onready var stats: Control = $"../Stats"

signal died

var dmg: float = 31
var fireball_cooldown: float = 0.8
var death_animation_duration: float = 4.0
var equipped_wand: String = "Wood"
var equipped_shield: Node2D = null

var inventory = {
	"coins": 50,
	"shield": 0,
	"fireball": false,
}
var wands = {
	"Wood": 0,
	"Crystal": 29,
	"Mighty": 70,
}

func _physics_process(_delta: float) -> void:
	if $"../Shop".popup.visible:
		velocity = Vector2.ZERO
		play_animation("idle")
		return

	var direction = Vector2.ZERO
	var fire_direction = Vector2(
		Input.get_axis("fire_left", "fire_right"),
		Input.get_axis("fire_up", "fire_down"))
	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("up", "down")

	if health <= 0:
		play_animation("death")
		await sprite.animation_finished
		died.emit()
	elif fire_direction != Vector2.ZERO:
		attack(fire_direction)
	elif direction != Vector2.ZERO:
		velocity = direction.normalized() * speed
		play_animation("walk")
		sprite.flip_h = velocity.x < 0
		move_and_slide()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		play_animation("idle")

	handle_wrap_around(self)

func play_animation(animation_name: String) -> void:
	if sprite.animation != animation_name:
		sprite.play(animation_name)

	match animation_name:
		"attack Wood", "attack Crystal", "attack Mighty":
			sprite.offset = Vector2(0, -8)  # Adjust to center 32x32 animations
			if inventory["fireball"]:
				sprite.speed_scale = 1.4
		_:
			sprite.offset = Vector2.ZERO
			sprite.speed_scale = 1.0

func handle_wrap_around(entity: Node2D) -> void:
	var adjusted_screen_size = screen_size / 3

	# Horizontal wrap-around
	if entity.position.x > adjusted_screen_size.x / 2:
		entity.position.x = -adjusted_screen_size.x / 2
	elif entity.position.x < -adjusted_screen_size.x / 2:
		entity.position.x = adjusted_screen_size.x / 2

	# Vertical wrap-around
	if entity.position.y > adjusted_screen_size.y / 2:
		entity.position.y = -adjusted_screen_size.y / 2
	elif entity.position.y < -adjusted_screen_size.y / 2:
		entity.position.y = adjusted_screen_size.y / 2

func attack(fire_direction: Vector2) -> void:
	if $Attack_Cooldown.is_stopped():
		sprite.flip_h = fire_direction.x < 0
		play_animation("attack " + equipped_wand)

		var delay_timer = Timer.new()
		delay_timer.one_shot = true
		delay_timer.wait_time = fireball_cooldown / 2 if inventory["fireball"] else 0.4  # Synchronize with animation
		add_child(delay_timer)
		delay_timer.connect("timeout", Callable(self, "try_launch_fireball").bind(fire_direction))
		delay_timer.start()

		$Attack_Cooldown.start(fireball_cooldown)

func try_launch_fireball(fire_direction: Vector2) -> void:
	fire_direction = Vector2(
		Input.get_axis("fire_left", "fire_right"),
		Input.get_axis("fire_up", "fire_down")
	).normalized()

	if fire_direction != Vector2.ZERO:
		var fireball = fireball_scene.instantiate()
		if sprite.flip_h:
			fireball.position = position + Vector2(-9, -5)
		else:
			fireball.position = position + Vector2(9, -5)
		
		fireball.damage = dmg + wands[equipped_wand]
		fireball.set_direction(fire_direction)
		get_parent().add_child(fireball)

func damage(amount: float) -> bool:
	if not invin_timer.is_stopped():
		return false
	elif equipped_shield:
		equipped_shield.reduce_durability()
		invin_timer.start()
		return false
	else:
		health = max(0, health - amount)
		stats.update_health()
		$AnimationPlayer.play("damage")
		invin_timer.start()
		return true

func apply_slow(duration: float = 3.0) -> void:
	speed = 100.0 * 0.5     #normal_speed * slow_multiplier
	if not slow_timer.is_stopped():
		slow_timer.stop()
	slow_timer.wait_time = duration
	slow_timer.start()

func _on_slow_timer_timeout() -> void:
	speed = 100.0

func add_to_inventory(item: String) -> void:
	if item == "coin":
		inventory["coins"] += 1
		update_coin_ui()
	elif item == "shield":
		inventory["shield"] = 3
	else:
		inventory[item] = true

func update_coin_ui():
	stats.update_coin(inventory["coins"])
