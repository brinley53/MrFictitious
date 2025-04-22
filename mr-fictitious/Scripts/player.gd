"""
Script focused on the player, it has it's movement, attacks, and taking damage
Authors: Jose Leyba, Brinley Hull
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
const PROJECTILE_SPEED = 600.0 
#GLOBAL VARIABLES
var base_speed := SPEED
var buff_speed := 1.0
var debuff_speed := 1.0
var health = 100
var max_health = 100
var bullets = 3
var attack_radius_x = 20 
var attack_radius_y = 35
var attack_radius = 35
var can_attack = true  
var stealth = false
var health_items = 0;
var base_damage = 1
var current_damage = base_damage
var speed_buff_timer :Timer = null
var damage_buff_timer :Timer = null

var is_poisoned = false
var current_proc_count = 0
var poison_proc_count = 0
var poison_damage = 0

var can_play_footstep_sound:bool=true
var current_location:int = -1
var current_player_state:PLAYER_STATE=PLAYER_STATE.Explore
var evidence_collected = 0
#ONREADY VARIABLES
@onready var attack_area = $AttackArea
@onready var collision_shape = $PlayerCollision
@onready var sprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var bulletResource = preload("res://Resources/bullet.tres")
@onready var healthResource = preload("res://Resources/health_item.tres")
@onready var attack_sprite = $AttackArea/AttackSprite
@onready var health_bar = $HealthContainer/HealthBar
@onready var footstep_timer = $FootstepTimer
@onready var dialogue_manager = $DialogueManager
@onready var poison_timer = $PoisonTimer

#EXPORT VARIABLES
@export var inventory:Inventory;

#The attack area starts disabled
func _ready():
	health_bar.value = health
	attack_area.visible = false
	attack_area.monitoring = false 
	attack_area.monitorable = false
	for i in range(bullets):
		collectItem(bulletResource)
	Wwise.register_game_obj(self,self.name)
	Wwise.register_listener(self)
	Wwise.load_bank_id(AK.BANKS.SOUND)
	Wwise.load_bank_id(AK.BANKS.MUSIC)

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
	move_character(delta)
	if Input.is_action_just_pressed("attack") and can_attack:
		attack_sprite.play("attacking")
		attack()
		can_attack = false
	if Input.is_action_just_pressed("secondary_attack") and can_attack:
		shoot_projectile()
	
	if Input.is_action_just_pressed("increaseBullet"):
		collectItem(bulletResource)
		add_bullet()
	
	if Input.is_action_just_pressed("healthItem"):
		use_health_item()
	

func get_size() -> Vector2:
	return collision_shape.shape.size

#Moves using WASD (Input Map Defined), normalized to keep same speed any direction
func move_character(delta):
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

#Will attack directing at the position of the map, uses radius 
func attack():
	var bodies = $AttackArea.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Enemies"):
			body.reduce_enemy_health(5)
	play_sound(AK.EVENTS.PLAYER_KNIFE_SWING)
	attack_area.monitoring = true  
	attack_area.monitorable = true
	attack_timer.start(ATTACK_LOCK_TIME_MELEE)
	var mouse_position = get_global_mouse_position()
	var attack_direction = (mouse_position - global_position).normalized()
	attack_area.visible = true
	var collision_center = collision_shape.position
	var attack_offset = Vector2(attack_direction.x * attack_radius_x, attack_direction.y * attack_radius_y) + collision_center
	attack_area.position = attack_offset
	attack_area.rotation = attack_direction.angle()


#Fires the gun, only works when you have bullets
func shoot_projectile():
	if bullets > 0:  
		play_sound(AK.EVENTS.PLAYER_GUN_SHOOT)
		removeItem(bulletResource)
		bullets -= 1 
		var projectile = PROJECTILE_SCENE.instantiate()
		projectile.body_entered.connect(projectile._on_body_entered)
		get_parent().add_child(projectile)
		projectile.global_position = global_position
		var target_position = get_global_mouse_position()
		var direction = (target_position - global_position).normalized()
		projectile.velocity = direction * PROJECTILE_SPEED

#Called from enemies when dealing damage, when health reaches 0 you die
func reduce_player_health(damage):
	play_sound(AK.EVENTS.PLAYER_DAMAGE)
	health = health - damage
	health_bar.value = health
	if health <= 0:
		play_sound(AK.EVENTS.PLAYER_DEATH)
		get_tree().change_scene_to_file("res://Scenes/lost.tscn")
	
func increase_player_health(amount:int):
	health = min(health+amount,max_health)
	health_bar.value=health

#Attacks enemies when entering the attack area
func _on_attack_area_body_entered(body: Node2D) -> void:
	pass

#When timer runs out disable the attack area
func _on_attack_timer_timeout():
	can_attack = true 
	attack_area.visible = false 
	attack_area.monitoring = true  
	attack_area.monitorable = true

func _on_footstep_timer_timeout():
	can_play_footstep_sound=true
#Adds bullet back to the player	
func add_bullet():
	bullets += 1
	
func collectItem(item:InventoryItem):
	return inventory.insert(item)

func removeItem(item:InventoryItem):
	return inventory.remove(item)

func add_health_item():
	health_items+=1

func use_health_item():
	if removeItem(healthResource):
		health_items-=1
		increase_player_health(10)

func use_inventory_item():
	var action = inventory.use_item()
	match action:
		"HEALTH": 
			use_health_item()
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
	base_damage += damage_increase
	current_damage = base_damage  
	var poly_node := attack_area.get_node_or_null("CollisionPolygon2D")
	if poly_node:
		var points = poly_node.polygon.duplicate()
		for i in range(points.size()):
			points[i] *= shrink_factor
		poly_node.polygon = points
	if attack_sprite:
		attack_sprite.scale *= shrink_factor



func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_E):
		dialogue_manager.show_example_dialogue_balloon(load("res://dialogue.dialogue"), "start")
		return
	
	if event.is_action_pressed("inventorySlot"):
		inventory.equipSlot(int(event.as_text())-1)
	
	if event.is_action_pressed("use_inventory_item"):
		use_inventory_item()

func play_sound(id:int):
	Wwise.post_event_id(id,self)

func play_ambient_sound(location):
	play_sound(AK.EVENTS.PLAYMUSIC)
	match location:
		0:
			play_sound(AK.EVENTS.CAMP)
		1:
			play_sound(AK.EVENTS.FOREST)

		2:
			play_sound(AK.EVENTS.VILLAGE)
		3:
			pass
		4:
			pass
		_:
			print("Wrong room loser")
		
func play_footstep_sound(location:int):
	match location:
		0:
			play_sound(AK.EVENTS.PLAYER_STEP)
		1:
			play_sound(AK.EVENTS.PLAYER_STEP_MATERIAL_CRUNCH)
			play_sound(AK.EVENTS.PLAYER_STEP_MATERIAL_GRASS)
		2:
			play_sound(AK.EVENTS.PLAYER_STEP_MATERIAL_NORMAL)
		3:
			pass
		4:
			pass
		_:
			print("Wrong room loser")

func receive_current_location(location:int):
	print(location)
	play_sound(AK.EVENTS.EXPLORE)
	current_player_state = PLAYER_STATE.Explore
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
