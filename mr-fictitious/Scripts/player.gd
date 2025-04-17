"""
Script focused on the player, it has it's movement, attacks, and taking damage
Authors: Jose Leyba
Creation Date: 03/27/2025
Revisions:
	Brinley Hull - 4/2/2025: Animation
	Jose Leyba - 04/03/2025 - Attack Revamp
	Brinley Hull - 4/14/2025: Stealth
	Jose Leyba 4/17/2025: Speed Multiplier
"""
class_name Player
extends CharacterBody2D

#CONSTANTS
const SPEED = 300.0
const ATTACK_LOCK_TIME_MELEE = 0.5
const ATTACK_LOCK_TIME_Range = 2
const PROJECTILE_SCENE = preload("res://Scenes/projectile.tscn")  
const PROJECTILE_SPEED = 600.0 
#GLOBAL VARIABLES
var base_speed := SPEED
var speed_multiplier := 1.0
var health = 100
var max_health = 100
var bullets = 3
var attack_radius_x = 20 
var attack_radius_y = 35
var attack_radius = 35
var can_attack = true  
var stealth = false
var health_items = 0;
#ONREADY VARIABLES
@onready var attack_area = $AttackArea
@onready var collision_shape = $PlayerCollision
@onready var sprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var bulletResource = preload("res://Resources/bullet.tres")
@onready var healthResource = preload("res://Resources/health_item.tres")
@onready var attack_sprite = $AttackArea/AttackSprite
@onready var health_bar = $HealthContainer/HealthBar

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

func set_stealth(is_stealthy):
	stealth = is_stealthy

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
	
	velocity = direction * base_speed * speed_multiplier
	move_and_slide()


#Will attack directing at the position of the map, uses radius 
func attack():
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
	health = health - damage
	health_bar.value = health
	if health <= 0:
		get_tree().change_scene_to_file("res://Scenes/lost.tscn")
	
func increase_player_health(amount:int):
	health = min(health+amount,max_health)
	health_bar.value=health

#Attacks enemies when entering the attack area
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		body.reduce_enemy_health(1)

#When timer runs out disable the attack area
func _on_attack_timer_timeout():
	can_attack = true 
	attack_area.visible = false 
	attack_area.monitoring = true  
	attack_area.monitorable = true
	
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

#Changes the speed, called when on "goo"
func set_speed_multiplier(multiplier: float) -> void:
	speed_multiplier = multiplier

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
