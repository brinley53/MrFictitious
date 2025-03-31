"""
Script focused on the enemy, for now it just has a function to deal damage to the oplayer when close and to die when taking too much damage
Authors: Jose Leyba, Brinley Hull
Creation Date: 03/27/2025
Revisions:
	Brinley Hull - 3/30/2025: Enemy patrol
	Brinley Hull - 3/31/2025: Enemy chase player
"""
extends CharacterBody2D
#GLOBAL VARIABLES
#attributes
var health = 3
var speed = 100.0

#patrol points/variables
@export var point_a:Area2D;
@export var point_b:Area2D;
var target_point:Area2D;

#chase player variables
var chase_player = false
@export var player:Node2D;

func _ready():
	#set initial variables
	target_point = point_b

func _physics_process(delta: float) -> void:
	patrol()
	if chase_player:
		chase(player)

#When player is inside the Attack Area, Take Damage (Will be change to something more later)
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.reduce_player_health(1)

#Enemy patrol movement -> go from point A to point B
func patrol():
	# set direction to be towards target_point
	var direction = (target_point.global_position - global_position).normalized()
	velocity = direction * speed

	move_and_slide()	
	
	#if we're close to the target point, change patrol points as the target point
	if global_position.distance_to(target_point.global_position) < 5.0 and !chase_player:
		# Swap target between point A and B
		target_point = point_a if target_point == point_b else point_b
		#flipSprite()

#Takes damage, when life reaches 0 it dies
func reduce_enemy_health(damage):
	health = health - damage
	if health <= 0:
		queue_free()

func _on_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		chase_player = true

func _on_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase_player = false
		
func chase(body: Node2D) -> void:
	target_point = body.get_child(2)
