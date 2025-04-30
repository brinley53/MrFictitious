"""
Script for the final boss logic
Authors: Brinley Hull, Jose Leyba, Tej Gumaste, Sean Hammell
Creation Date: 04/28/2025
Revisions:
"""

extends CharacterBody2D

signal dead

const BULLET_SCENE = preload("res://Scenes/Enemies/syringe.tscn")  
const EVIDENCE_SCENE = preload("res://Scenes/evidence.tscn")  

#GLOBAL VARIABLES
# stats attributes
var speed : float
@export var health : float
@export var damage : float
var attack = "Chase"
var syringe_types = ["Poison", "Snail", "Weak"]

#chase player variables
var chase_player = false
var attack_player = false
var stunned = false
var current_stun_timer: Timer = null
var num_shots = 0
# On ready attributes
@onready var attack_timer = $AttackTimer
@onready var sprite = $AnimatedSprite2D
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]
@onready var health_bar = $HealthContainer/HealthBar
@onready var attack_area = $AttackArea
@onready var switch_attack_timer = $BigAttackTimer
@onready var shot_timer = $ShotTimer
@onready var triple_timer = $TripleShotTimer

func _ready():
	#set initial variables
	speed = 150.0
	
func change_attack(attack_type):
	if stunned:
		return
	attack = attack_type
	if attack == "Shot":
		shoot_player()
	
func shoot_player():
	if stunned or player.stealth or attack != "Shot" or player.in_dialogue:
		return
	shot_timer.start()
	triple_timer.start()

func _physics_process(_delta: float) -> void:
	if stunned or player.in_dialogue:
		return
	if !player.stealth:
		# Calculate the direction vector towards the player
		var direction = (player.global_position - global_position).normalized()

		# Rotate the sprite towards the player
		if direction.x > 0:
			sprite.flip_h = true  # Not flipped
		else:
			sprite.flip_h = false  # Flip horizontally
				
		if attack == "Chase":
			velocity = (player.global_position - global_position).normalized() * speed
			move_and_slide()
	else:
		summon_workers()
		
func summon_workers():
	pass

#Takes damage, when life reaches 0 it dies
func reduce_enemy_health(damage_dealt):
	health = health - damage_dealt
	health_bar.value = health
	if health <= 0:
		var item = EVIDENCE_SCENE.instantiate()
		var angle = randf() * TAU 
		var radius = randf_range(64.0, 128.0)
		var offset = Vector2(cos(angle), sin(angle)) * radius
		item.global_position = global_position + offset
		get_tree().current_scene.add_child(item)
		queue_free()
		dead.emit()

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

#When player is inside the Attack Area, Take Damage (Will be change to something more later)
func _on_attack_area_body_entered(body: Node2D) -> void:
	if stunned:
		return
	if body.name == "Player":
		attack_player = true
		player.reduce_player_health(damage)
		attack_timer.start()

func _on_attack_area_body_exited(body: Node2D) -> void:
	# When player escapes, don't reduce health anymore
	if body.name == "Player":
		attack_player = false
			
func _on_attack_timer_timeout() -> void:
	# timer to allow player iframes
	if stunned:
		return
	if attack_player:
		player.reduce_player_health(damage)
		attack_timer.start()

func _on_shot_timer_timeout() -> void:
	# Time between each individual shot for quick triple shot succession
	if num_shots >= 3:
		num_shots = 0
		shot_timer.stop()
		return
	var bullet = BULLET_SCENE.instantiate()
	bullet.body_entered.connect(bullet._on_body_entered)
	bullet.global_position = global_position
	bullet.initialize_bullet(player.global_position, syringe_types[randi_range(0, 2)])
	get_parent().add_child(bullet)
	num_shots += 1
	shot_timer.start()

func _on_triple_shot_timer_timeout() -> void:
	# time between triple shotssss
	shoot_player()

func _on_big_attack_timer_timeout() -> void:
	if attack == "Shot":
		change_attack("Chase")
	else:
		change_attack("Shot")
	switch_attack_timer.start()
