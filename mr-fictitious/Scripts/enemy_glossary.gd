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
		"description": "Small enemies that have infested the map with disease and distress.\n
		 Perhaps these pests have been taking advantage of the dead all around.  "
	},
	"wolf": {
		"texture": preload("res://images/GlossaryCuts/wolf sprite sheet right facing.png"),
		"name": "Wolf",
		"type": "Basic Enemy",
		"description": "During the war wolves would hunt injured and dead soldiers. These \n
		critters can be found across the map."
	},
	"mendoza": {
		"texture": preload("res://images/GlossaryCuts/cryptbossidle.webp"),
		"name": "Mendoza",
		"type": "Head of the Asylum",
		"description": "Head of the Asylum. Responsible for all the misfortune that has befallen \n
		you. His journal entries give a deeper look at his psyche. They can be discovered in each \n
		location on the map."
	},
	"poison": {
		"texture": preload("res://images/GlossaryCuts/assylum worker sprite-Sheet-Sheet.png"),
		"name": "Asylum Workers",
		"type": "Basic Enemy",
		"description": "Enemies you’re quite familiar with these foes. Mendoza has sent them to hunt \n
		you down after your escape from the asylum."
	},
	"statue": {
		"texture": preload("res://images/GlossaryCuts/angel attack sprite-Sheet.png"),
		"name": "The Fallen Archangel",
		"type": "Town Center Statue",
		"description": "Serves as the main spectator on all activities in the village."
	},
	"skull": {
		"texture": preload("res://images/GlossaryCuts/hoodenemyrightface.png"),
		"name": "Hooded Skulls",
		"type": "Minion Enemies",
		"description": "Enemies located in the Crypt. Their purpose is to guard The Horseman."
	},
	"horseman": {
		"texture": preload("res://images/GlossaryCuts/hoodenemyrightface.png"),
		"name": "The Horseman",
		"type": "Pr	otector of Dead Souls",
		"description": "Located in Crypt, this boss is the pride and joy of its creator.\n
		 It is guarded by Hooded creatures. "
	}
	# Add more...
}

func _ready():
	for btn in $EnemyGrid.get_children():
		btn.connect("pressed", Callable(self, "_on_enemy_pressed").bind(btn.name))
	print("Glossary visible: ", visible)
	print("Glossary position: ", position)
	print("Glossary size: ", size)
	set_process(true)
	set_anchors_preset(Control.PRESET_FULL_RECT)

func _process(delta):
	queue_redraw()

func _on_enemy_pressed(enemy_key: String):
	var data = enemy_data.get(enemy_key)
	if data:
		enemy_image.texture = data.texture
		enemy_name.text = data.name
		enemy_type.text = data.type
		enemy_description.text = data.description


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/title.tscn")
