extends Node2D

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var label_press_e = $"Label(Press E)"
@onready var animation_player = $AnimationPlayer
@onready var popup = $Popup
@onready var popup_sprite = $Popup/Sprite2D
@onready var popup_description = $Popup/Description
@onready var purchase_button = $Popup/Control/Button

signal next_wave

var items = {
	"Crystal Wand": {"cost": 10, "description": "+10 Damage", "purchased": false, "texture": preload("res://assets/Little Mage1-1/_Staffs/staff_crystal.png")},
	"Mighty Wand": {"cost": 20, "description": "+20 Damage", "purchased": false, "texture": preload("res://assets/Little Mage1-1/_Staffs/staff_mighty.png")},
	"Shield Of Fire": {"cost": 5, "description": "Blocks 3 Attacks", "purchased": false, "texture": preload("res://assets/shield of fire-idle.png")}
}

var current_item = null

func _ready():
	label_press_e.visible = false
	popup.visible = false

func _process(_delta):
	if popup.visible and Input.is_action_just_pressed("E") or Input.is_action_just_pressed("Esc"):
		popup.visible = false
		$"Next Wave/Button".disabled = false
	elif current_item and Input.is_action_just_pressed("E"):
		open_popup()
	
	if popup.visible and current_item and items[current_item]["purchased"] and (not purchase_button.disabled):
		purchase_button.disabled = true

func _on_crystal_area_entered(_body: Node2D):
	var item_name: String = "Crystal Wand" 
	current_item = item_name
	label_press_e.visible = true
	animation_player.play("fade_in_out")

func _on_mighty_area_entered(_body: Node2D):
	var item_name: String = "Mighty Wand"
	current_item = item_name
	label_press_e.visible = true
	animation_player.play("fade_in_out")

func _on_shield_area_entered(_body: Node2D):
	var item_name: String = "Shield Of Fire" 
	current_item = item_name
	label_press_e.visible = true
	animation_player.play("fade_in_out")

func _on_item_area_exited(_body: Node2D):
	current_item = null
	label_press_e.visible = false
	animation_player.stop()

func open_popup():
	popup.visible = true
	popup_sprite.texture = items[current_item]["texture"]
	popup_description.text = current_item + "\n\n" + items[current_item]["description"]
	purchase_button.text = str(items[current_item]["cost"]) + " Buy"
	$"Next Wave/Button".disabled = true

	var player_coins = player.inventory["coins"]
	if player_coins >= items[current_item]["cost"] or items[current_item]["purchased"]:
		purchase_button.disabled = false
	else:
		purchase_button.disabled = true

	player.play_animation("idle")


func _on_purchase_pressed():
	var cost = items[current_item]["cost"]
	if player.inventory["coins"] >= cost:
		if current_item.begins_with("Mighty"):
			items["Mighty Wand"]["purchased"] = true
			items["Crystal Wand"]["purchased"] = true
		elif current_item.begins_with("Crystal"):
			items["Crystal Wand"]["purchased"] = true
		elif current_item.begins_with("Shield"):
			items["Shield Of Fire"]["purchased"] = true

		player.inventory["coins"] -= cost
		player.update_coin_ui()
		if player.inventory["coins"] < items[current_item]["cost"]:
			purchase_button.disabled = true

		if current_item == "Crystal Wand" or current_item == "Mighty Wand":
			player.equipped_wand = current_item.split(" ", false, 1)[0]
		elif current_item == "Shield Of Fire":
			var shield = load("res://scenes/shield_of_fire.tscn")
			shield = shield.instantiate()
			self.get_parent().add_child(shield)
			player.inventory["shield"] = 3
			shield.position = player.global_position

func disable_shop():
	$".".visible = false
	popup.visible = false
	label_press_e.visible = false
	animation_player.stop()
	current_item = null
	$"Frog/CollisionShape2D".disabled = true
	
	for area in get_children():
		if area is Area2D:
			for child in area.get_children():
				if child is CollisionShape2D:
					child.set_deferred("disabled", true)

func enable_shop():
	$"Frog/CollisionShape2D".disabled = false
	$".".visible = true
	for area in get_children():
		if area is Area2D:
			for child in area.get_children():
				if child is CollisionShape2D:
					child.set_deferred("disabled", false)

func _on_next_wave_pressed() -> void:
	next_wave.emit()
