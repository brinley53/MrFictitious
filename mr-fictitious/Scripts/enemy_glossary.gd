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
		"description": "Small enemies that have infested the map with disease and distress. Perhaps these pests have 
		been taking advantage of the dead all around.  "
	},
	"wolf": {
		"texture": preload("res://images/GlossaryCuts/wolf sprite sheet right facing.png"),
		"name": "Wolf",
		"type": "Basic Enemy",
		"description": "During the war wolves would hunt injured and dead soldiers. These critters can be found 
		across the map."
	},
	"mendoza": {
		"texture": preload("res://images/GlossaryCuts/Doctorstance.png"),
		"name": "Mendoza",
		"type": "Head of the Asylum",
		"description": "Head of the Asylum. Responsible for all the misfortune that has befallen you. His journal 
		entries give a deeper look at his psyche. They can be discovered in each location on the map."
	},
	"worker": {
		"texture": preload("res://images/GlossaryCuts/assylum worker sprite-Sheet-Sheet.png"),
		"name": "Asylum Workers",
		"type": "Basic Enemy",
		"description": "Enemies you’re quite familiar with these foes. Mendoza has sent them to hunt you down after 
		your escape from the asylum."
	},
	"griffins": {
	"texture": preload("res://images/GlossaryCuts/small griffin staute sprite sheet right facing .png"),
	"name": "Flying Guardians",
	"type": "Basic Enemy",
	"description": "The favorite sons of the Town Protector. They monitor the village 24/7 looking for intruders. "
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
		"texture": preload("res://images/GlossaryCuts/cryptbossidle.webp"),
		"name": "The Horseman",
		"type": "Protector of Dead Souls",
		"description": "Located in Crypt, this boss is the pride and joy of its creator. It is guarded by Hooded 
		creatures. "
	},
	"flash": {
		"texture": preload("res://images/GlossaryCuts/flashlight.png"),
		"name": "Flashlight",
		"type": "Usable Item",
		"description": "Used to indicate troop location to planes above during the war, this item is now useful
		for your needs. Grants light when in dark or dim locations. Especially when facing off with foes in these
		types of areas. "
	},
	"pills": {
		"texture": preload("res://images/GlossaryCuts/speed pill sprite.png"),
		"name": "Cocaine Pills",
		"type": "Usable Item",
		"description": "Used as anesthetic and chloroform for surgeries during wartime. Gives the player extra 
		speed for a certain time. Useful when running from enemy combatants."
	},
	"shot": {
		"texture": preload("res://images/GlossaryCuts/strength shot (its meth shhhh).png"),
		"name": "Syringe",
		"type": "Usable Item",
		"description": "This syringe contains unknown medication that boost your damage temporarily. Only God 
		knows what the liquid inside really is... "
	},
	"medicine": {
		"texture": preload("res://images/GlossaryCuts/health pack.png"),
		"name": "Morphine",
		"type": "Usable Item",
		"description": "Leftover narcotic from the Great War used to kill pain and sometimes injured soldiers. 
		Boosts players health. Useful when you are close to death but aren't ready to go yet. "
	},
	"shovel": {
		"texture": preload("res://images/GlossaryCuts/shovel sprite.png"),
		"name": "Tactical Shovel",
		"type": "Weapon",
		"description": "Used both in and out of combat, perfect tools for survival on the wilderness it looks 
		like it has seen better days. Deals less damage than the standart knife but it attacks in a bigger 
		area(40 Uses) "
	},
	"rifle": {
		"texture": preload("res://images/GlossaryCuts/MGweapon.png"),
		"name": "Modified Musket",
		"type": "Weapon",
		"description": "This rifle has seen some modifications by some assylum workers. The bullets now split
		into 3 sections. Perfect for rooms with multiple enemies (25 Uses) "
	},
	"sword": {
		"texture": preload("res://images/GlossaryCuts/swordweapon.png"),
		"name": "Saber",
		"type": "Weapon",
		"description": "Used by Infantry Officers and Cavalrymen, sabers swords were used for close quarters 
		combat away from the trenches. Now you can use it to help fend off and damage any enemies that come 
		your way. Attacks in a circle area (45 Uses) "
	},
	"tent": {
		"texture": preload("res://images/GlossaryCuts/tent.png"),
		"name": "Nameless Soldier",
		"type": "Ally",
		"description": "Another inmate who escaped alongside you. Fought on the War with you. He can be found in
		the woods by a tent, there you can stop and converse with him."
	},
	"evidence": {
		"texture": preload("res://images/GlossaryCuts/evidence.png"),
		"name": "Evidence",
		"type": "Evidence",
		"description": "Four in total, these journal entries slowly reveal secrets involving experiments going on 
		around the map. Three evidence papers must be collected to enter the Asylum."
	},
	"forest": {
		"texture": preload("res://images/GlossaryCuts/Forest.png"),
		"name": "Forest",
		"type": "Location",
		"description": "A former battlefield during The Great War. This is the first area you’ll see when you begin 
		your journey. Leads to all three areas of the map. Face off again enemies in this area and talk to a fellow 
		escaped Inmate camping outside the asylum. An journal entry can be discovered here. "
	},
	"crypt": {
		"texture": preload("res://images/GlossaryCuts/Crypt.png"),
		"name": "Crypt",
		"type": "Location",
		"description": "Home of the dead and long forgotten. They were once your allies but have been transformed 
		into something sinister. Guarded by Hooded creatures, this location harbors The Horseman. A journal entry 
		can be discovered here.  "
	},
	"town": {
		"texture": preload("res://images/GlossaryCuts/Crypt.png"),
		"name": "Village",
		"type": "Location",
		"description": "Your previous home. Now a forgotten memory. Not many are left here. Most of what remains 
		are The Guardians, statues that monitor the village 24/7. Near the center of the village is statue of a
		archangel, which serves as the main spectator on all activities. A journal entry can be discovered here. "
	},
	"assylum": {
		"texture": preload("res://images/GlossaryCuts/Crypt.png"),
		"name": "Assylum",
		"type": "Location",
		"description": "All roads lead back to here. This location can only be entered after acquiring the three 
		journal entries. When you acquire them, Dr. Mendoza, head of the Asylum, will be waiting for you."
	},
	
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
	Wwise.post_event_id(AK.EVENTS.MENU_TEXT,self)
	var data = enemy_data.get(enemy_key)
	if data:
		enemy_image.texture = data.texture
		enemy_name.text = data.name
		enemy_type.text = data.type
		enemy_description.text = data.description


func _on_button_pressed() -> void:
	Wwise.post_event_id(AK.EVENTS.MENU_CLICK,self)
	get_tree().change_scene_to_file("res://Scenes/title.tscn")
