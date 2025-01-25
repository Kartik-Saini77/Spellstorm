extends TileMapLayer

var target_alpha: float = 0.0
var fade_speed: float = 2.0

func _ready():
	set_process(false)
	pass

func _process(delta: float):
	print("hello")
	var current_alpha = modulate.a
	if current_alpha != target_alpha:
		var new_alpha = lerp(current_alpha, target_alpha, fade_speed * delta)
		modulate.a = new_alpha

		if abs(new_alpha - target_alpha) < 0.01:
			modulate.a = target_alpha
			set_process(false)

func visible(speed):
	fade_speed=speed
	target_alpha = 1.0
	set_process(true)

func hidden(speed):
	fade_speed=speed
	target_alpha = 0.0
	set_process(true)
