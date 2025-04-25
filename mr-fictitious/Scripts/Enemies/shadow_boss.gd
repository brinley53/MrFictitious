"""
Script for the shadow crypt boss logic
Authors: Brinley Hull, Jose Leyba
Creation Date: 04/17/2025
Revisions:
		Jose Leyba - 04/21/2025: Boss drops the "key" (evidence) for final area when killed
		Brinley Hull - 4/22/2025: Boss movement and vulnerability
		Brinley Hull - 4/23/2025: Different boss attacks
"""

extends CharacterBody2D

signal dead

const BULLET_SCENE = preload("res://Scenes/Enemies/shadow_bullet.tscn")  
const EVIDENCE_SCENE = preload("res://Scenes/evidence.tscn")  

#GLOBAL VARIABLES
# stats attributes
var speed : float
@export var health : float
@export var damage : float
var is_vulnerable = true
var attack = "Default"

#chase player variables
var chase_player = false
var attack_player = false
var dir_facing = 1

# On ready attributes
@onready var timer = $AttackTimer
@onready var sprite = $AnimatedSprite2D
@onready var detection = $Detection
@onready var vul_timer = $VulnerableTimer
@onready var vul_area = $VulnerableArea
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]
@onready var health_bar = $HealthContainer/HealthBar


func _ready():
	#set initial variables
	speed = 10.0
	timer.start()
	
func reset_patrol():
	chase_player = false
	speed = 10.0
	attack_player = false
	
func change_attack(attack_type):
	attack = attack_type
	
func shoot_player():
	var bullet = BULLET_SCENE.instantiate()
	bullet.body_entered.connect(bullet._on_body_entered)
	bullet.global_position = global_position
	bullet.initialize_bullet(player.global_position, attack)
	get_parent().add_child(bullet)

func _physics_process(delta: float) -> void:
	reduce_enemy_health(20 * delta)
	if !player.stealth:
		# Calculate the direction vector towards the player
		var direction = (player.global_position - global_position).normalized()

		# Rotate the sprite towards the player
		if direction.x > 0:
			sprite.flip_h = true  # Not flipped
		else:
			sprite.flip_h = false  # Flip horizontally
			

		# Rotate the detection area to face the playe
		
		direction = (player.global_position - detection.global_position).angle() + PI
		detection.rotation = lerp_angle(detection.rotation, direction, delta)
		vul_area.scale.x = 1 if (player.global_position - global_position).normalized().x > 0 else -1
		
		velocity = (player.global_position - global_position).normalized() * speed
		move_and_slide()

#Takes damage, when life reaches 0 it dies
func reduce_enemy_health(damage_dealt):
	if !is_vulnerable:
		return
	health = health - damage_dealt
	health_bar.value = health
	print("Health taken")
	if health <= 0:
		var item = EVIDENCE_SCENE.instantiate()
		var angle = randf() * TAU 
		var radius = randf_range(64.0, 128.0)
		var offset = Vector2(cos(angle), sin(angle)) * radius
		item.global_position = global_position + offset
		get_tree().current_scene.add_child(item)
		queue_free()
		dead.emit()

#When player is inside the Attack Area, Take Damage (Will be change to something more later)
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		attack_player = true
		player.reduce_player_health(damage)
		timer.start()

func _on_detection_body_entered(body: Node2D) -> void:
	# If player enters cone of detection, chase the player
	if body.name == "Player":
		chase_player = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	# When player escapes, don't reduce health anymore
	if body.name == "Player":
		attack_player = false
			
func _on_attack_timer_timeout() -> void:
	# timer to allow player iframes
	if !player.stealth and chase_player:
		shoot_player()
	timer.start()

func _on_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase_player = false

func _on_vulnerable_area_body_entered(body: Node2D) -> void:
	pass

func _on_vulnerable_timer_timeout() -> void:
	is_vulnerable = true
	
func _on_vulnerable_area_area_entered(area: Area2D) -> void:
	if !chase_player:
		is_vulnerable = true
		vul_timer.start()
