###
	#Player Script
# Script focused on the player, it has it's movement, attacks, and taking damage
#Creation Date: 03/27/2025
	#Revisions# 
# Jose Leyba -- 03/27/2025 -- Creation of player.gd
###
extends CharacterBody2D

#CONSTANTS
const SPEED = 300.0
#GLOBAL VARIABLES
var health = 5
var attack_radius = 20
#ONREADY VARIABLES
@onready var attack_area = $AttackArea
@onready var collision_shape = $PlayerCollision

#Every frame call the move_character function, calls the attack function when pressing left click
func _process(delta):
	move_character(delta)
	if Input.is_action_just_pressed("attack"):
		attack()

#Moves using WASD (Input Map Defined), normalized to keep same speed any direction
func move_character(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	
	if direction.length() > 0:
		direction = direction.normalized()
	
	velocity = direction * SPEED
	move_and_slide()


#Will attack directing at the position of the map, uses radius 
func attack():
	var mouse_position = get_global_mouse_position()
	var attack_direction = (mouse_position - global_position).normalized()
	attack_area.visible = true
	var collision_center = collision_shape.position
	var attack_offset = attack_direction * attack_radius + collision_center
	attack_area.position = attack_offset

#Called from enemies when dealing damage, when health reaches 0 you die
func reduce_player_health(damage):
	health = health - damage
	if health <= 0:
		queue_free()



#USEFUL FOR LATER WHEN IMPLEMENTING GUNS. DO NOT DELETE
#func start_attack(direction):
	#attack_area.visible = true
	#var collision_center = collision_shape.position
	## Calculate the local offset for the attack area relative to the player
	#var attack_offset = direction * attack_radius + collision_center
	#
	#var tween = get_tree().create_tween()
	#tween.tween_property(attack_area, "position", attack_offset, attack_time)
	#
	#await tween.finished
	#attack_area.visible = false
	#attack_area.position = Vector2.ZERO  # Reset position after attack
