extends Control

@onready var enemy_image = $InfoPanel/EnemyImage
@onready var enemy_name = $InfoPanel/EnemyName
@onready var enemy_type = $InfoPanel/EnemyType
@onready var enemy_description = $InfoPanel/EnemyDescription

var enemy_data = {
	"rat": {
		"texture": preload("res://images/GlossaryCuts/Ratstanding.png"),
		"name": "Sewer Rat",
		"type": "Basic Enemy",
		"description": "This type of rat has been invading towns in search for food, they hunger for human flesh."
	},
	"wolf": {
		"texture": preload("res://images/GlossaryCuts/Wolf_White_Background.png"),
		"name": "Wolf",
		"type": "Basic Enemy",
		"description": "Wolfs have been living in the forest for longer than the town has been around, be \n careful not to perturb them."
	}
	# Add more...
}

func _ready():
	for btn in $EnemyGrid.get_children():
		btn.connect("pressed", Callable(self, "_on_enemy_pressed").bind(btn.name))

func _on_enemy_pressed(enemy_key: String):
	var data = enemy_data.get(enemy_key)
	if data:
		enemy_image.texture = data.texture
		enemy_name.text = data.name
		enemy_type.text = data.type
		enemy_description.text = data.description


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/title.tscn")
