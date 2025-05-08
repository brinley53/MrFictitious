"""
Script focused on the player, it has it's movement, attacks, and taking damage
Authors: Jose Leyba, Brinley Hull, Tej Gumaste
Creation Date: 03/27/2025
Revisions:
	Brinley Hull - 4/2/2025: Animation
	Jose Leyba - 04/03/2025 - Attack Revamp
	Brinley Hull - 4/14/2025: Stealth
	Jose Leyba 4/17/2025: Speed Multiplier
	Tej Gumaste 4/17/2025: Sound integration with dynamic sounds
	Brinley Hull - 4/17/2025: Dialogue
	Brinley Hull - 4/18/2025: 
		- Fix Attack Area Body Entered Bug
		- Poison
	Brinley Hull - 4/22/2025: Shadows
	Jose Leyba  - 4/24/2025: Items use inventory now, added new weapons
	Brinley Hull - 4/27/2025: Dialogue pause boolean
	Tej Gumaste - 4/27/2025 : Removed Overlapping music
	Brinley Hull - 4/29/2025: All dialogue
	Brinley Hull - 5/1/2025: Enemy knockback
	Brinley Hull - 5/6/2025: Hit enemy on first swing
"""
class_name Player
extends CharacterBody2D

#CONSTANTS
enum PLAYER_STATE {
	Combat,
	Explore
}
const SPEED = 300.0
const ATTACK_LOCK_TIME_MELEE = 0.5
const FOOTSTEP_FREQUENCY=0.4
const ATTACK_LOCK_TIME_Range = 2
const PROJECTILE_SCENE = preload("res://Scenes/projectile.tscn")
const SHOVEL = preload("res://Scenes/shovel.tscn")
const SWORD = preload("res://Scenes/sword.tscn")
const MUSKET_PROJECTILE_SCENE = preload("res://Scenes/musket_projectile.tscn")
const PROJECTILE_SPEED = 600.0 
#GLOBAL VARIABLES
var base_speed := SPEED
var buff_speed := 1.0
var debuff_speed := 1.0
var health = 200
var max_health = 200
var bullets = 3
var attack_radius_x = 20 
var attack_radius_y = 35
var attack_radius = 35
var can_attack = true  
var stealth = false
var health_items = 0
var flashlight_items = 0
var dmg_items = 0
var speed_items = 0

var base_damage = 5
var damage_difference = 0
var current_damage = base_damage
var speed_buff_timer :Timer = null
var damage_buff_timer :Timer = null

var is_poisoned = false
var current_proc_count = 0
var poison_proc_count = 0
var poison_damage = 0

var dialogue_balloon

var can_play_footstep_sound:bool=true
var current_location:int = -1
var current_player_state:PLAYER_STATE=PLAYER_STATE.Explore
var evidence_collected = 0
var in_dialogue = false

var spin_attack_active = false
var orbit_timer = 0.0
var orbit_duration = 0.75  # How long the orbit lasts
var orbit_speed = 3 * PI 

#Weapon Variables
var sword = false
var has_shovel = false
var has_musket = false
var sword_attack_uses = 0
var max_sword_attacks = 45
var shovel_attack_uses = 0
var max_shovel_attacks = 40
var musket_attack_uses = 0
var max_musket_attacks = 15
var original_polygon = []
var original_sprite_scale = Vector2.ONE
var start = true
var can_shoot = true

#ONREADY VARIABLES
@onready var attack_area = $AttackArea
@onready var collision_shape = $PlayerCollision
@onready var sprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var bulletResource = preload("res://Resources/bullet.tres")
@onready var healthResource = preload("res://Resources/health_item.tres")
@onready var flashResource = preload("res://Resources/flashlight_item.tres")
@onready var DmgResource = preload("res://Resources/damage_item.tres")
@onready var SpeedResource = preload("res://Resources/speed_item.tres")
@onready var MusketResource = preload("res://Resources/musket.tres")
@onready var ShovelResource = preload("res://Resources/shovel.tres")
@onready var SwordResource = preload("res://Resources/sword.tres")
@onready var proof1 = preload("res://proof1.dialogue")
@onready var read = preload("res://read.dialogue")
@onready var attack_sprite = $AttackArea/AttackSprite
@onready var attack_sprite_spin = $SpinNode/SpinArea/AttackSprite
@onready var health_bar = $HealthContainer/HealthBar
@onready var footstep_timer = $FootstepTimer
@onready var dialogue_manager = $DialogueManager
@onready var poison_timer = $PoisonTimer
@onready var stealth_area = $Stealth
@onready var spin_node = $SpinNode
@onready var spin_area = $SpinNode/SpinArea
@onready var gun_cooldown = $GunCooldown

#EXPORT VARIABLES
@export var inventory:Inventory
@export var weapon_inventory:Inventory

#The attack area starts disabled
func _ready():
	health_bar.max_value = health
	health_bar.value = health
	attack_area.visible = false
	attack_area.monitoring = false 
	attack_area.monitorable = false
	spin_node.visible = false
	spin_area.monitoring = false
	spin_area.monitorable = false

	for i in range(bullets):
		collectItem(bulletResource)
	Wwise.register_game_obj(self,self.name)
	Wwise.register_listener(self)
	Wwise.load_bank_id(AK.BANKS.MUSIC)
	Wwise.load_bank_id(AK.BANKS.SOUND)
	Wwise.set_rtpc_value_id(AK.GAME_PARAMETERS.PLAYER_HEALTH,100,self)
	play_sound(AK.EVENTS.PLAYMUSIC)
	play_sound(AK.EVENTS.ZERO)
	
	# Dialogue signal connections
	dialogue_manager.connect("dialogue_ended", Callable(self, "_on_dialogue_finished"))
	dialogue_manager.connect("dialogue_started", Callable(self, "_on_dialogue_started"))


func set_stealth(is_stealthy):
	stealth = is_stealthy
	
func poison(pp, pd):
	# function for enemies to call to poison the player, taking in the poison proc count and the poison damage dealt
	is_poisoned = true
	poison_timer.start()
	poison_proc_count = pp
	current_proc_count = 0
	poison_damage = pd

#Every frame call the move_character function, calls the attack function when pressing left click
func _process(delta):	
	var overlapping_areas = stealth_area.get_overlapping_areas()
	stealth = false
	for area in overlapping_areas:
		if area.is_in_group("Shadow") and area.enabled:  # or type check
			stealth = true
			sprite.modulate = Color(0.3, 0.3, 0.3, 1.0)
			break
			
	if !stealth:
		sprite.modulate=Color.WHITE
	
	move_character(delta)
	if in_dialogue:
		if dialogue_balloon == null or dialogue_manager.dialogue_end:
			in_dialogue = false
		else:
			return
	if Input.is_action_just_pressed("attack") and can_attack and !sword:
		if has_shovel:
			shovel_attack_uses += 1
			removeWeapon(ShovelResource)
			if shovel_attack_uses >= max_shovel_attacks:
				reset_shovel()
		attack_sprite.play("attacking")
		attack()
		can_attack = false
	if Input.is_action_just_pressed("secondary_attack") and can_attack:
		shoot_projectile()
	if Input.is_action_just_pressed("read"):
		read_evidence()
	if spin_attack_active:
		orbit_timer += delta
		spin_node.rotation += orbit_speed * delta
		if orbit_timer >= orbit_duration:
			end_spin_attack()

	if Input.is_action_just_pressed("attack") and can_attack and sword:
		attack_sprite_spin.play("attacking_spin")
		removeWeapon(SwordResource)
		start_spin_attack()
	
	if Input.is_action_just_pressed("increaseBullet"):
		collectItem(bulletResource)
		add_bullet()
	
	if Input.is_action_just_pressed("healthItem"):
		use_health_item()
	
	if health<=0:
		reduce_player_health(1)
	

func get_size() -> Vector2:
	return collision_shape.shape.size

func read_evidence():
	if evidence_collected == 0:
		return
	if evidence_collected == 1:
		dialogue_balloon = dialogue_manager.show_dialogue_balloon(read, "start")
	if evidence_collected == 2:
		dialogue_balloon = dialogue_manager.show_dialogue_balloon(read, "evidence2")
	if evidence_collected == 3:
		dialogue_balloon = dialogue_manager.show_dialogue_balloon(read, "evidence3")
	if evidence_collected == 4:
		get_tree().change_scene_to_file("res://Scenes/title.tscn")
	if dialogue_balloon != null:
		dialogue_balloon.connect("balloon_closed", Callable(self, "_on_balloon_closed"))
#Moves using WASD (Input Map Defined), normalized to keep same speed any direction
func move_character(_delta):
	var direction = Vector2.ZERO
	var animation = "stand_down" 
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
		animation = "walk_up"
	if Input.is_action_pressed("move_down"):
		direction.y += 1
		animation = "walk_down"
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
		animation = "walk_left"
	if Input.is_action_pressed("move_right"):
		direction.x += 1
		animation = "walk_right"
	
	if direction.length() > 0:
		direction = direction.normalized()
	
	if (sprite.animation != animation):
		sprite.play(animation)
	if direction!=Vector2.ZERO:
		if can_play_footstep_sound:
			can_play_footstep_sound=false
			play_sound(AK.EVENTS.PLAYER_STEP)
			footstep_timer.start(FOOTSTEP_FREQUENCY)
	velocity = direction * base_speed * buff_speed * debuff_speed
	move_and_slide()
	
func hit_enemy(body):
	if body.is_in_group("Enemies") and body.has_method("reduce_enemy_health"):
		body.reduce_enemy_health(current_damage)
		if body.has_method("knockback"):
			body.knockback(global_position)

#Will attack directing at the position of the map, uses radius 
func attack():
	attack_area.monitoring = true  
	attack_area.monitorable = true
			
	play_sound(AK.EVENTS.KNIFE_SWING)
	attack_timer.start(ATTACK_LOCK_TIME_MELEE)
	var mouse_position = get_global_mouse_position()
	var attack_direction = (mouse_position - global_position).normalized()
	attack_area.visible = true
	var collision_center = collision_shape.position
	var attack_offset = Vector2(attack_direction.x * attack_radius_x, attack_direction.y * attack_radius_y) + collision_center
	attack_area.position = attack_offset
	attack_area.rotation = attack_direction.angle()

func new_evidence_collected(evidence:Evidence):
	inventory.collect_evidence(evidence)
	evidence_collected += 1
	if evidence_collected == 1:
		play_sound(AK.EVENTS.ONE)
		dialogue_balloon = dialogue_manager.show_dialogue_balloon(proof1, "start")
	if evidence_collected == 2:
		play_sound(AK.EVENTS.TWO)
		dialogue_balloon = dialogue_manager.show_dialogue_balloon(proof1, "start")
	if evidence_collected == 3:
		play_sound(AK.EVENTS.THREE)
		dialogue_balloon = dialogue_manager.show_dialogue_balloon(proof1, "start")
	if dialogue_balloon != null:
		dialogue_balloon.connect("balloon_closed", Callable(self, "_on_balloon_closed"))

# Dialogue start functions
func final_boss_dialogue():
	dialogue_balloon = dialogue_manager.show_dialogue_balloon(load("res://dialogue.dialogue"), "mendoza")
	dialogue_balloon.connect("balloon_closed", Callable(self, "_on_balloon_closed"))

func starting_dialogue():
	dialogue_balloon = dialogue_manager.show_dialogue_balloon(load("res://dialogue.dialogue"), "start")
	dialogue_balloon.connect("balloon_closed", Callable(self, "_on_balloon_closed"))

func inmate_dialogue():
	if in_dialogue:
		return
	if evidence_collected < 2:
		if start:
			starting_dialogue()
			start = false
		else:
			dialogue_balloon = dialogue_manager.show_dialogue_balloon(load("res://dialogue.dialogue"), "inmate")
	else:
		dialogue_balloon = dialogue_manager.show_dialogue_balloon(load("res://dialogue.dialogue"), "evidence2")	
	dialogue_balloon.connect("balloon_closed", Callable(self, "_on_balloon_closed"))
	
func evidence_dialogue():
	if in_dialogue:
		return
	if evidence_collected == 0:
		dialogue_balloon = dialogue_manager.show_dialogue_balloon(load("res://dialogue.dialogue"), "evidence0")
	elif evidence_collected == 1:
		dialogue_balloon = dialogue_manager.show_dialogue_balloon(load("res://dialogue.dialogue"), "evidence1")
	dialogue_balloon.connect("balloon_closed", Callable(self, "_on_balloon_closed"))

func asylum_blocker_dialogue():
	if in_dialogue:
		return

	if evidence_collected < 3:
		dialogue_balloon = dialogue_manager.show_dialogue_balloon(load("res://dialogue.dialogue"), "blocker")
		dialogue_balloon.connect("balloon_closed", Callable(self, "_on_balloon_closed"))

#Fires the gun, only works when you have bullets
func shoot_projectile():
	if bullets > 0 and can_shoot:  
		
		removeItem(bulletResource)
		bullets -= 1 
		gun_cooldown.start()
		can_shoot = false
		if has_musket:
			play_sound(AK.EVENTS.RIFLE_SHOOT)
			removeWeapon(MusketResource)
			musket_attack_uses += 1
			if musket_attack_uses >= max_musket_attacks:
				has_musket = false
			var projectile = MUSKET_PROJECTILE_SCENE.instantiate()
			var manager = get_node("/root/Main/RoomManager")
			var room = manager.get_active_room()
			room.add_child(projectile)
			projectile.global_position = global_position
			var target_position = get_global_mouse_position()
			var direction = (target_position - global_position).normalized()
			projectile.velocity = direction * PROJECTILE_SPEED
		else:
			play_sound(AK.EVENTS.PISTOL_SHOOT)
			var projectile = PROJECTILE_SCENE.instantiate()
			var manager = get_node("/root/Main/RoomManager")
			var room = manager.get_active_room()
			room.add_child(projectile)
			projectile.global_position = global_position
			var target_position = get_global_mouse_position()
			var direction = (target_position - global_position).normalized()
			projectile.velocity = direction * PROJECTILE_SPEED
	elif bullets <= 0:
		play_sound(AK.EVENTS.PISTOL_DRY_FIRE)

#Functions for swinging attack
func start_spin_attack():
	if sword and sword_attack_uses < max_sword_attacks:
		spin_attack_active = true
		orbit_timer = 0.0
		can_attack = false
		spin_node.visible = true
		spin_area.visible = true
		spin_area.monitoring = true
		spin_area.monitorable = true
		sword_attack_uses += 1
		if sword_attack_uses >= max_sword_attacks:
			sword = false

func end_spin_attack():
	spin_attack_active = false
	can_attack = true
	spin_node.visible = false
	spin_area.visible = false
	spin_area.monitoring = false
	spin_area.monitorable = false

func collect_sword_weapon():
	sword = true
	if has_shovel:
		reset_shovel()
		for i in range(max_shovel_attacks - shovel_attack_uses):
			removeWeapon(ShovelResource)
		var new_shovel = SHOVEL.instantiate()
		var manager = get_node("/root/Main/RoomManager")
		var room = manager.get_active_room()
		room.add_child(new_shovel)
		new_shovel.global_position = global_position + Vector2(0,200)
	for i in range(max_sword_attacks - sword_attack_uses):
		collectWeapon(SwordResource)
	sword_attack_uses = 0

func collect_musket_weapon():
	has_musket = true
	musket_attack_uses = 0

#Called from enemies when dealing damage, when health reaches 0 you die
func reduce_player_health(damage):
	play_sound(AK.EVENTS.PLAYER_HURT)
	health = health - damage
	health_bar.value = health
	Wwise.set_rtpc_value_id(AK.GAME_PARAMETERS.PLAYER_HEALTH,health,self)
	if health <= 0:
		print("u dead bro")
		# Wwise.unload_bank_id(AK.BANKS.SOUND)
		# Wwise.unload_bank_id(AK.BANKS.MUSIC)
		if inventory:
			inventory.clear()
		if weapon_inventory:
			weapon_inventory.clear()
		Wwise.stop_all(self)
		get_tree().change_scene_to_file("res://Scenes/lost.tscn")
	
func increase_player_health(amount:int):
	health = min(health+amount,max_health)
	health_bar.value=health

#Attacks enemies when entering the attack area
func _on_attack_area_body_entered(body: Node2D) -> void:
	hit_enemy(body)

func _on_spin_area_area_entered(area: Area2D) -> void:
	# Check for statue area hit
	var body = area.get_parent()
	if body.name == "Statue" and area.name in ["LeftWing", "RightWing", "Head"] or area.name=="Vulnerable":
		if area.name=="Vulnerable":
			body = body.get_parent()
		if body.has_method("reduce_enemy_health"):
			body.reduce_enemy_health(current_damage, area.name)


#When timer runs out disable the attack area
func _on_attack_timer_timeout():
	can_attack = true 
	attack_area.visible = false 
	attack_area.monitoring = false  
	attack_area.monitorable = false

func _on_footstep_timer_timeout():
	can_play_footstep_sound=true
#Adds bullet back to the player	
func add_bullet():
	bullets += 1
	
func collectItem(item:InventoryItem):
	return inventory.insert(item)


func collectWeapon(item:InventoryItem):
	return weapon_inventory.insert(item)

func removeItem(item:InventoryItem):
	return inventory.remove(item)

func removeWeapon(item:InventoryItem):
	return weapon_inventory.remove(item)
	
func add_health_item():
	health_items+=1

func add_flashlight_item():
	flashlight_items+=1

func add_damage_item():
	dmg_items+=1

func add_speed_item():
	speed_items+=1

func use_flashlight_item():
	if removeItem(flashResource):
		flashlight_items-=1
		var enemies = get_tree().get_nodes_in_group("Enemies")
		for enemy in enemies:
			if enemy.has_method("apply_stun"):
				enemy.apply_stun(5.0)

func use_health_item():
	if removeItem(healthResource):
		health_items-=1
		increase_player_health(20)

func use_dmg_item():
	if removeItem(DmgResource):
		apply_damage_buff(10, 5)


func use_speed_item():
	print(SpeedResource)
	if removeItem(SpeedResource):
		apply_speed_buff(1.5, 5)
func use_inventory_item():
	var action = inventory.use_item()
	match action:
		"HEALTH": 
			use_health_item()
		"FLASH":
			use_flashlight_item()
		"DMG":
			use_dmg_item()
		"SPEED":
			print("Speedy Boy")
			use_speed_item()
		_:
			print("Invalid Option")
				
		
	
#Changes the speed, called when on "goo" (Debuffs Speed)
func set_speed_multiplier(multiplier: float) -> void:
	debuff_speed = multiplier

#FUNCTIONS RELATED TO TEMPORARY ITEMS
#Gives additional Speed for X seconds
func apply_speed_buff(boost: float, duration: float):
	buff_speed = boost
	if speed_buff_timer:
		speed_buff_timer.stop()
	else:
		speed_buff_timer = Timer.new()
		speed_buff_timer.one_shot = true
		speed_buff_timer.timeout.connect(_remove_speed_buff)
		add_child(speed_buff_timer)

	speed_buff_timer.wait_time = duration
	speed_buff_timer.start()

#Ends Speed Buff
func _remove_speed_buff():
	buff_speed = 1.0

#Gives additional Damage for X seconds
func apply_damage_buff(boost: int, duration: float):
	current_damage = base_damage + boost
	if damage_buff_timer:
		damage_buff_timer.stop()
	else:
		damage_buff_timer = Timer.new()
		damage_buff_timer.one_shot = true
		damage_buff_timer.timeout.connect(_remove_damage_buff)
		add_child(damage_buff_timer)

	damage_buff_timer.wait_time = duration
	damage_buff_timer.start()

#Ends Damage Buff
func _remove_damage_buff():
	current_damage = base_damage

#END OF TEMPORARY BUFF FUNCTIONS

#PERMANENT CHANGES
#Trades Attack Area for DMG
func shovel(damage_increase: int, shrink_factor: float):
	if sword:
		for i in range(max_sword_attacks - sword_attack_uses):
			removeWeapon(SwordResource)
		var new_sword = SWORD.instantiate()
		var manager = get_node("/root/Main/RoomManager")
		var room = manager.get_active_room()
		room.add_child(new_sword)
		new_sword.global_position = global_position + Vector2(0,200)
		sword = false
	for i in range(max_shovel_attacks - shovel_attack_uses):
		collectWeapon(ShovelResource)
	has_shovel = true
	base_damage += damage_increase
	damage_difference = damage_increase
	current_damage = base_damage 
	var poly_node := attack_area.get_node_or_null("CollisionPolygon2D")
	if poly_node:
		var points = poly_node.polygon.duplicate()
		for i in range(points.size()):
			points[i] *= shrink_factor
		poly_node.polygon = points
	if attack_sprite:
		attack_sprite.scale *= shrink_factor

func reset_shovel():
	base_damage -= damage_difference
	damage_difference = 0
	current_damage = base_damage
	has_shovel = false

	var poly_node := attack_area.get_node_or_null("CollisionPolygon2D")
	if poly_node:
		var points = poly_node.polygon.duplicate()
		for i in range(points.size()):
			points[i] *= 0.7
		poly_node.polygon = points
	if attack_sprite:
		attack_sprite.scale *= 0.7

func _on_dialogue_started(_resource: DialogueResource):
	# Function to pause everything while dialogue is on
	in_dialogue = true

func _on_dialogue_finished(_resource: DialogueResource):
	# Function to resume everything when dialogue is done
	in_dialogue = false
	
func _on_balloon_closed(_resource: DialogueResource):
	in_dialogue = false

func _input(event: InputEvent) -> void:
	# Skip dialogue option
	if in_dialogue and Input.is_key_pressed(KEY_ENTER):
		in_dialogue = false
		if dialogue_balloon != null:
			dialogue_balloon.end_dialogue()
	
	if event.is_action_pressed("inventorySlot"):
		inventory.equipSlot(int(event.as_text())-1)
	
	if event.is_action_pressed("use_inventory_item"):
		use_inventory_item()

func play_sound(id:int):
	Wwise.post_event_id(id,self)

func play_ambient_sound(location):
	print("Playing ambient sound ",location)
	Wwise.stop_all()
	play_sound(AK.EVENTS.PLAYMUSIC)
	play_sound(AK.EVENTS.GAMEPLAY)
	#CENTRAL,
	#FOREST,
	#CRYPT,
	#VILLAGE,
	#ASYLUM,
	#COUNT
	match location:
		0:
			play_sound(AK.EVENTS.CENTRAL)
			play_sound(AK.EVENTS.GAME_AREA_FOREST)
		1:
			play_sound(AK.EVENTS.FOREST)
			play_sound(AK.EVENTS.GAME_AREA_FOREST)
		2:
			play_sound(AK.EVENTS.CRYPT)
			play_sound(AK.EVENTS.GAME_AREA_CRYPT)
		3:
			play_sound(AK.EVENTS.VILLAGE)
			play_sound(AK.EVENTS.GAME_AREA_TOWN)
		4:
			play_sound(AK.EVENTS.ASYLUM)
			play_sound(AK.EVENTS.GAME_AREA_ASYLUM)
		_:
			print("Wrong room loser")

func receive_current_location(location, central=false, is_boss_room=false):
	if dialogue_balloon != null:
		dialogue_balloon.end_dialogue()
		in_dialogue = false
	if !central:
		start = false
	current_player_state = PLAYER_STATE.Explore
	if(is_boss_room):
		play_sound(AK.EVENTS.BOSS)
	else:
		play_sound(AK.EVENTS.EXPLORE)
		if current_location!=location:
			current_location=location
			play_ambient_sound(current_location)
	

func initiate_combat():
	if current_player_state!=PLAYER_STATE.Combat:
		play_sound(AK.EVENTS.COMBAT)
		current_player_state=PLAYER_STATE.Combat
	
#Might be useful later, rn not, leave it here for now
#func start_attack_range():
	#attack_area.visible = true
	#attack_timer.start(ATTACK_LOCK_TIME_MELEE)
	#var mouse_position = get_global_mouse_position()
	#var attack_direction = (mouse_position - global_position).normalized()
	#var collision_center = collision_shape.position
	## Calculate the local offset for the attack area relative to the player
	#var attack_offset = attack_direction * attack_radius + collision_center
	#
	#var tween = get_tree().create_tween()
	#tween.tween_property(attack_area, "position", attack_offset, 2)
	#
	#await tween.finished
	#attack_area.visible = false
	#attack_area.position = Vector2.ZERO  # Reset position after attack

#Function to poison the player
func _on_poison_timer_timeout() -> void:
	if is_poisoned:
		# Check if we're over the proc count to be done with poison
		if current_proc_count >= poison_proc_count:
			is_poisoned = false
		else:
			reduce_player_health(poison_damage)
			current_proc_count+=1
			poison_timer.start()
			
func update_volume(val: float):
	Wwise.set_rtpc_value_id(AK.GAME_PARAMETERS.SOUND_VOLUME,val,self)

func update_music_volume(val: float):
	Wwise.set_rtpc_value_id(AK.GAME_PARAMETERS.MUSIC_VOLUME,val,self)


func _on_attack_area_area_entered(area: Area2D) -> void:
	# Check for statue area hit
	var body = area.get_parent()
	if body.name == "Statue" and area.name in ["LeftWing", "RightWing", "Head"] or area.name=="Vulnerable":
		if area.name=="Vulnerable":
			body = body.get_parent()
		if body.has_method("reduce_enemy_health"):
			body.reduce_enemy_health(current_damage, area.name)


func _on_spin_area_body_entered(body: Node2D) -> void:
	hit_enemy(body)


func _on_gun_cooldodwn_timeout() -> void:
	can_shoot = true
