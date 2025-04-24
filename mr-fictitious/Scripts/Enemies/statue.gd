"""
Script for the statue boss logic
Authors: Brinley Hull
Creation Date: 04/15/2025
Revisions:
	Brinley Hull - 4/24/2025: 
		- Animation
		- Death Logic
		- Basic Attacks
"""
extends CharacterBody2D
#GLOBAL VARIABLES
# stats attributes
var left_wing_health : int
var right_wing_health : int
var head_health : int
var speed : float
@export var base_speed : float
@export var damage : float

#chase player variables
var chase_player = false
var attack_player = false
var attack_type = "Pound"
var attack_types = ["Pound", "Charge"]

# On ready attributes
@onready var timer = $AttackTimer
@onready var big_attack_timer = $BigAttackTimer
@onready var sprite = $AnimatedSprite2D
@onready var detection = $Detection
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]

func _ready():
	#set initial variables
	speed = base_speed
	left_wing_health = 3
	right_wing_health = 3
	head_health = 5
	sprite.play("pound")

func _physics_process(delta: float) -> void:
	# Die if its arms are off
	if left_wing_health <= 0 and right_wing_health <= 0 and head_health <= 0:
		queue_free()

#When player is inside the Attack Area, Take Damage (Will be change to something more later)
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		attack_player = true
		player.reduce_player_health(damage)
		timer.start()

func _on_detection_body_entered(body: Node2D) -> void:
	# If player enters cone of detection, chase the player
	if body.name == "Player":
		if !body.stealth:
			chase_player = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	# When player escapes, don't reduce health anymore
	if body.name == "Player":
		attack_player = false
			

func _on_attack_timer_timeout() -> void:
	# timer to allow player iframes
	if attack_player:
		player.reduce_player_health(damage)
		timer.start()


func _on_head_area_entered(area: Area2D) -> void:
	if area.is_in_group("Weapon"):
		head_health -= 1


func _on_right_wing_area_entered(area: Area2D) -> void:
	if area.is_in_group("Weapon"):
		right_wing_health -= 1


func _on_left_wing_area_entered(area: Area2D) -> void:
	if area.is_in_group("Weapon"):
		left_wing_health -= 1

func ground_pound():
	sprite.play("pound")
	
func charge():
	pass

func _on_big_attack_timer_timeout() -> void:
	big_attack_timer.start()
	if attack_type == "Pound":
		ground_pound()
	else:
		charge()
		
	attack_type = attack_types[randi_range(0, 1)];


func _on_animated_sprite_2d_animation_finished() -> void:
	sprite.play("default")
