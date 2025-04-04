"""
Script focused on the player, it has it's movement, attacks, and taking damage
Authors: Jose Leyba
Creation Date: 03/27/2025
Revisions:
	Brinley Hull - 4/2/2025: animation
	Jose Leyba - 04/03/2025 - Attack Revamp
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
var health = 5
var bullets = 3
var attack_radius_x = 20 
var attack_radius_y = 35
var attack_radius = 35
var can_attack = true  
#ONREADY VARIABLES
@onready var attack_area = $AttackArea
@onready var collision_shape = $PlayerCollision
@onready var sprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer

#EXPORT VARIABLES
@export var inventory:Inventory;

#The attack area starts disabled
func _ready():
	attack_area.visible = false
	attack_area.monitoring = false 
	attack_area.monitorable = false


#Every frame call the move_character function, calls the attack function when pressing left click
func _process(delta):
	move_character(delta)
	if Input.is_action_just_pressed("attack") and can_attack:
		attack()
		can_attack = false
	if Input.is_action_just_pressed("secondary_attack") and can_attack:
		shoot_projectile()

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
	
	velocity = direction * SPEED
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
		bullets -= 1 
		var projectile = PROJECTILE_SCENE.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position
		var target_position = get_global_mouse_position()
		var direction = (target_position - global_position).normalized()
		projectile.velocity = direction * PROJECTILE_SPEED

#Called from enemies when dealing damage, when health reaches 0 you die
func reduce_player_health(damage):
	health = health - damage
	if health <= 0:
		queue_free()	


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
