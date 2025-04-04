"""
Script for wolf enemy
Authors: Jose Leyba, Brinley Hull
Creation Date: 04/04/2025
Revisions:
	Brinley Hull - 4/4/2025, dynamic player variable
"""
extends CharacterBody2D
#GLOBAL VARIABLES
# stats attributes
var health = 5
var speed = 60.0

#patrol points/variables
@export var point_a:Area2D
@export var point_b:Area2D
var target_point:Area2D

#chase player variables
var chase_player = false
var attack_player = false

# On ready attributes
@onready var timer = $AttackTimer
@onready var sprite = $AnimatedSprite2D
@onready var detection = $Detection
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]

func _ready():
	#set initial variables
	target_point = point_b

func _physics_process(delta: float) -> void:
	patrol()
	if chase_player:
		chase(player)
		sprite.play("run")
		speed = 150.0
	else:
		sprite.play("walk")
		speed = 60.0

#When player is inside the Attack Area, Take Damage (Will be change to something more later)
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		attack_player = true
		player.reduce_player_health(1)
		timer.start()

#Enemy patrol movement -> go from point A to point B
func patrol():
	# set direction to be towards target_point
	if target_point == null:
		target_point = point_a
		chase_player = false
	var direction = (target_point.global_position - global_position).normalized()
	velocity = direction * speed
	
	# face the sprite and detection cone based on what direction we're going
	if direction.x > 0:
		sprite.flip_h = 0
		detection.scale.x = 1
	else:
		sprite.flip_h = 1
		detection.scale.x =  -1

	move_and_slide()	
	
	#if we're close to the target point, change patrol points as the target point
	if global_position.distance_to(target_point.global_position) < 5.0 and !chase_player:
		# Swap target between point A and B
		target_point = point_a if target_point == point_b else point_b
	
#Takes damage, when life reaches 0 it dies
func reduce_enemy_health(damage):
	health = health - damage
	if health <= 0:
		queue_free()

func _on_detection_body_entered(body: Node2D) -> void:
	# If player enters cone of detection, chase the player
	if body.name == "Player":
		chase_player = true
		
func chase(body: Node2D) -> void:
	# Change target point to be the player's area2d child
	target_point = body.get_child(2)

func _on_attack_area_body_exited(body: Node2D) -> void:
	# When player escapes, don't reduce health anymore
	if body.name == "Player":
		attack_player = false

func _on_attack_timer_timeout() -> void:
	# timer to allow player iframes
	if attack_player:
		player.reduce_player_health(25)
		timer.start()
