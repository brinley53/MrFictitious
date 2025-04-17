"""
Script for the shadow crypt boss logic
Authors: Brinley Hull
Creation Date: 04/17/2025
Revisions:
"""

extends CharacterBody2D

#GLOBAL VARIABLES
# stats attributes
var speed : float
@export var base_speed : float
@export var damage : float

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
	speed = base_speed
	left_arm_health = 3
	right_arm_health = 3

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
		poison_timer.start()
		current_proc_count = 0
			
func _on_attack_timer_timeout() -> void:
	# timer to allow player iframes
	if attack_player:
		player.reduce_player_health(damage)
		timer.start()
