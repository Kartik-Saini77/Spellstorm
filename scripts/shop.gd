extends Node2D

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")
@onready var label_press_e = $"Label(Press E)"
@onready var animation_player = $AnimationPlayer
@onready var popup = $Popup
@onready var popup_sprite = $Popup/Sprite2D
@onready var popup_description = $Popup/Description
@onready var purchase_button = $Popup/Control/Button
@onready var shield: Node2D = get_tree().get_first_node_in_group("shop_items")

var items = {
	"Crystal Wand": {"cost": 15, "description": "+10 Damage", "purchased": false, "texture": preload("res://assets/Little Mage1-1/_Staffs/staff_crystal.png")},
	"Mighty Wand": {"cost": 25, "description": "+20 Damage", "purchased": false, "texture": preload("res://assets/Little Mage1-1/_Staffs/staff_mighty.png")},
	"Shield Of Fire": {"cost": 5, "description": "Blocks 3 Attacks", "purchased": false, "texture": preload("res://assets/shield of fire-idle.png")}
}

var current_item = null

func _ready():
	label_press_e.visible = false
	popup.visible = false

func _process(_delta):
	if popup.visible and Input.is_action_just_pressed("E"):
		popup.visible = false
	elif current_item and Input.is_action_just_pressed("E"):
		open_popup()

func _on_crystal_area_entered(body: Node2D):
	var item_name: String = "Crystal Wand" 
	print(item_name)
	current_item = item_name
	label_press_e.visible = true
	animation_player.play("fade_in_out")
	
func _on_mighty_area_entered(body: Node2D):
	var item_name: String = "Mighty Wand"
	print(item_name)
	current_item = item_name
	label_press_e.visible = true
	animation_player.play("fade_in_out")

func _on_shield_area_entered(body: Node2D):
	var item_name: String = "Shield Of Fire" 
	print(item_name)
	current_item = item_name
	label_press_e.visible = true
	animation_player.play("fade_in_out")

func _on_item_area_exited(_body: Node2D):
	print("exit")
	current_item = null
	label_press_e.visible = false
	animation_player.stop()

func open_popup():
	popup.visible = true
	popup_sprite.texture = items[current_item]["texture"]
	popup_description.text = current_item + "\n\n" + items[current_item]["description"]
	purchase_button.text = str(items[current_item]["cost"]) + " Buy"

	var player_coins = player.inventory["coins"]
	if player_coins >= items[current_item]["cost"] or items[current_item]["purchased"]:
		purchase_button.disabled = false
	else:
		purchase_button.disabled = true

	player.play_animation("idle")


func _on_purchase_pressed():
	var cost = items[current_item]["cost"]
	if current_item and player.inventory["coins"] >= cost:
		if not current_item.begins_with("Shield Of Fire"):
			items[current_item]["purchased"] = true
			purchase_button.disabled = true
		player.inventory["coins"] -= cost
		player.update_coin_ui()

		if current_item == "Crystal Wand" or current_item == "Mighty Wand":
			player.equipped_wand = current_item.split(" ", false, 1)[0]
		elif current_item == "Shield Of Fire":
			player.inventory["shield"] = 3
			player.equipped_shield = shield
			shield.state = shield.ShieldState.EQUIPPED	#call update_animation() in the game code

		print("Purchased:", current_item)
