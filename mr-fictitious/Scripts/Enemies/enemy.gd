"""
Script for all things enemy
Authors: Jose Leyba, Brinley Hull
Creation Date: 03/27/2025
Revisions:
	Brinley Hull - 3/30/2025: Enemy patrol
	Brinley Hull - 3/31/2025: Enemy chase player
	Brinley Hull - 4/2/2025: 
		- Enemy faces its movement direction
		- Player I-frames/attack timer
	Brinley Hull - 4/4/2025
		- Dynamic Player Variable
		- Flip Detection Point Up
		- Modular for Other Enemy Types
	Brinley Hull - 4/11/2025: Poison enemy
	Brinley Hull - 4/14/2025: Shadows
	Brinley Hull - 4/15/2025: Detect player on hit
	Tej Gumaste - 4/17/2025: Added combat sounds
"""
extends CharacterBody2D
#GLOBAL VARIABLES
# stats attributes
@export var health : int
var speed : float
@export var base_speed : float
@export var damage : float
@export var poison_proc_count : int
var current_proc_count = 0

#patrol points/variables
@export var point_a:Area2D
@export var point_b:Area2D
var target_point:Area2D

#chase player variables
var chase_player = false
var attack_player = false
var poison = false

# On ready attributes
@onready var timer = $AttackTimer
@onready var sprite = $AnimatedSprite2D
@onready var detection = $Detection
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]
@export_enum("Wolf", "Rat", "Poison") var type : String

func _ready():
	#set initial variables
	target_point = point_b
	speed = base_speed
	
func reset_patrol():
	chase_player = false
	speed = base_speed
	attack_player = false
	target_point = point_a

func _physics_process(delta: float) -> void:
	if player.stealth and chase_player:
		reset_patrol()
	patrol()
	if chase_player:
		chase(player)
		sprite.play("run")
		if (type == "Wolf"):
			speed = base_speed * 2.5
	else:
		sprite.play("walk")
		speed = base_speed

#When player is inside the Attack Area, Take Damage (Will be change to something more later)
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		attack_player = true
		player.initiate_combat()
		player.reduce_player_health(damage)
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
	else:
		sprite.flip_h = 1
		
	if velocity.length() > 0:
		detection.rotation = velocity.angle()

	move_and_slide()	
	
	#if we're close to the target point, change patrol points as the target point
	if global_position.distance_to(target_point.global_position) < $CollisionShape2D.shape.radius and !chase_player:
		# Swap target between point A and B
		target_point = point_a if target_point == point_b else point_b
	
#Takes damage, when life reaches 0 it dies
func reduce_enemy_health(damage_dealt):
	health = health - damage_dealt
	chase_player = true
	player.initiate_combat()
	if health <= 0:
		queue_free()

func _on_detection_body_entered(body: Node2D) -> void:
	# If player enters cone of detection, chase the player
	if body.name == "Player":
		if !body.stealth:
			player.initiate_combat()
			chase_player = true
		
func chase(body: Node2D) -> void:
	# Change target point to be the player's area2d child
	target_point = body.get_child(2)

func _on_attack_area_body_exited(body: Node2D) -> void:
	# When player escapes, don't reduce health anymore
	if body.name == "Player":
		attack_player = false
		if (type == 'Poison'):
			player.poison(poison_proc_count, damage)			

func _on_attack_timer_timeout() -> void:
	# timer to allow player iframes
	if attack_player:
		player.reduce_player_health(damage)
		timer.start()
