"""
Script for the statue boss logic
Authors: Brinley Hull
Creation Date: 04/15/2025
Revisions:
	Brinley Hull - 4/24/2025: 
		- Animation
		- Death Logic
		- Basic Attacks
	Jose Leyba  4/24/2025: Statue Stun
	Brinley Hull - 4/27/2025: Ground pound attack
	Brinley Hull - 4/30/2025: Fix vulnerable area bullet detection
"""
extends CharacterBody2D
#GLOBAL VARIABLES
# stats attributes
var left_wing_health : int
var right_wing_health : int
var head_health : int
var speed : float
var charge_speed : float
var target : Vector2
@export var base_speed : float
@export var damage : float

#chase player variables
var chase_player = false
var attack_player = false
var attack_type = "Pound"
var attack_types = ["Pound", "Charge"]
var stunned = false
var current_stun_timer: Timer = null
var total_health:int

var sprite_string = "lhr"

# On ready attributes
@onready var timer = $AttackTimer
@onready var big_attack_timer = $BigAttackTimer
@onready var sprite = $AnimatedSprite2D
#@onready var detection = $Detection
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]
@onready var health_bar = $HealthContainer/HealthBar
@onready var pound_area = $PoundArea
@onready var pound_sprite = $PoundArea/AnimatedSprite2D
@onready var pound_timer = $PoundTimer
@onready var head = $Head
@onready var r_wing = $RightWing
@onready var l_wing = $LeftWing


func _ready():
	#set initial variables
	target = global_position
	speed = base_speed
	left_wing_health = 3
	right_wing_health = 3
	head_health = 5
	charge_speed = 750.0
	total_health = left_wing_health + right_wing_health + head_health
	pound_sprite.visible = false

func _physics_process(delta: float) -> void:
	health_bar.value = (left_wing_health+right_wing_health+head_health)*100/total_health
	if stunned:
		return
	if global_position.distance_to(target) < sprite.sprite_frames.get_frame_texture("default_" + sprite_string, 0).get_size().x/4:
		speed = 0.0
	# Die if its arms are off
	if left_wing_health <= 0 and right_wing_health <= 0 and head_health <= 0:
		queue_free()
	var direction = (target - global_position).normalized()
	velocity = speed * direction
	position += velocity * delta

#When player is inside the Attack Area, Take Damage (Will be change to something more later)
func _on_attack_area_body_entered(body: Node2D) -> void:
	if stunned:
		return
	if body.name == "Player":
		attack_player = true
		player.reduce_player_health(damage)
		timer.start()

func _on_detection_body_entered(body: Node2D) -> void:
	# If player enters cone of detection, chase the player
	if stunned:
		return
	if body.name == "Player":
		if !body.stealth:
			chase_player = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	# When player escapes, don't reduce health anymore
	if body.name == "Player":
		attack_player = false
			

func _on_attack_timer_timeout() -> void:
	if stunned:
		return
	# timer to allow player iframes
	if attack_player:
		player.reduce_player_health(damage)
		timer.start()

func apply_stun(duration):
	if stunned and current_stun_timer:
		current_stun_timer.stop()
		current_stun_timer.queue_free()
	stunned = true
	current_stun_timer = Timer.new()
	current_stun_timer.one_shot = true
	current_stun_timer.wait_time = duration
	add_child(current_stun_timer)
	current_stun_timer.connect("timeout", Callable(self, "_on_stun_timeout"))
	current_stun_timer.start()

func _on_stun_timeout():
	stunned = false
	if current_stun_timer:
		current_stun_timer.queue_free()
		current_stun_timer = null

func reduce_enemy_health(_damage_dealt, area_hit=""):
	if area_hit == "":
		var rwing_areas = r_wing.get_overlapping_areas()
		var head_areas = head.get_overlapping_areas()
		var lwing_areas = l_wing.get_overlapping_areas()
		if left_wing_health > 0:
			for area in lwing_areas:
				if area.is_in_group("Weapon"):
					left_wing_health -= 1
					change_sprite()
					return
		if right_wing_health > 0:
			for area in rwing_areas:
				if area.is_in_group("Weapon"):
					right_wing_health -= 1
					change_sprite()
					return
		if head_health > 0:
			for area in head_areas:
				if area.is_in_group("Weapon"):
					head_health -= 1
					change_sprite()
					return
	else:
		if area_hit == "LeftWing" and left_wing_health > 0:
			left_wing_health -= 1
			change_sprite()
			return
		if area_hit == "RightWing" and right_wing_health > 0:
			right_wing_health -= 1
			change_sprite()
			return
		if area_hit == "Head" and head_health > 0:
			head_health -= 1
			change_sprite()
			return
				
func change_sprite():
	sprite_string = ""
	if left_wing_health > 0:
		sprite_string += "l"
	if head_health > 0:
		sprite_string += "h"
	if right_wing_health > 0:
		sprite_string += "r"
	sprite.play("default_" + sprite_string)

func ground_pound():
	sprite.play("pound_" + sprite_string)
	pound_timer.start()
	
func charge():
	speed = charge_speed
	target = player.global_position

func _on_big_attack_timer_timeout() -> void:
	big_attack_timer.start()
	if attack_type == "Pound":
		ground_pound()
	else:
		charge()
		
	attack_type = attack_types[randi_range(0, 1)];


func _on_animated_sprite_2d_animation_finished() -> void:
	pound_sprite.visible = true
	pound_sprite.play("pound")
	sprite.play("default_" + sprite_string)

func _on_pound_timer_timeout() -> void:
	#pound_sprite.visible = false
	pass

func _on_pound_sprite_2d_animation_finished() -> void:
	if pound_sprite.animation == "pound":
		pound_sprite.play("unpound")
		for body in pound_area.get_overlapping_bodies():
			if body == player:
				player.reduce_player_health(30)
	elif pound_sprite.animation == "unpound":
		pound_sprite.visible = false
		
