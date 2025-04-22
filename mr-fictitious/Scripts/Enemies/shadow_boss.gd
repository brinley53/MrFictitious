"""
Script for the shadow crypt boss logic
Authors: Brinley Hull, Jose Leyba
Creation Date: 04/17/2025
Revisions:
		Jose Leyba - 04/21/2025: Boss drops the "key" (evidence) for final area when killed
"""

extends CharacterBody2D

const BULLET_SCENE = preload("res://Scenes/Enemies/shadow_bullet.tscn")  
const EVIDENCE_SCENE = preload("res://Scenes/evidence.tscn")  


#GLOBAL VARIABLES
# stats attributes
var speed : float
@export var health : float
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
	timer.start()
	
func reset_patrol():
	chase_player = false
	speed = base_speed
	attack_player = false
	
func shoot_player():
	var bullet = BULLET_SCENE.instantiate()
	bullet.body_entered.connect(bullet._on_body_entered)
	bullet.global_position = global_position
	bullet.initialize_bullet(player.global_position, 500)
	get_parent().add_child(bullet)

func _physics_process(delta: float) -> void:
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
		#detection.look_at(player.global_position)
		#detection.rotation += PI

#Enemy patrol movement -> go from point A to point B
#func patrol():
	## set direction to be towards target_point
	#if target_point == null:
		#target_point = point_a
		#chase_player = false
	#var direction = (target_point.global_position - global_position).normalized()
	#velocity = direction * speed
	#
	## face the sprite and detection cone based on what direction we're going
	#if direction.x > 0:
		#sprite.flip_h = 0
	#else:
		#sprite.flip_h = 1
		#
	#if velocity.length() > 0:
		#detection.rotation = velocity.angle()
#
	#move_and_slide()	
	
	##if we're close to the target point, change patrol points as the target point
	#if global_position.distance_to(target_point.global_position) < $CollisionShape2D.shape.radius and !chase_player:
		## Swap target between point A and B
		#target_point = point_a if target_point == point_b else point_b
	#
#Takes damage, when life reaches 0 it dies
func reduce_enemy_health(damage_dealt):
	health = health - damage_dealt
	print("Health taken")
	chase_player = true
	if health <= 0:
		var item = EVIDENCE_SCENE.instantiate()
		var angle = randf() * TAU 
		var radius = randf_range(64.0, 128.0)
		var offset = Vector2(cos(angle), sin(angle)) * radius
		item.global_position = global_position + offset
		get_tree().current_scene.add_child(item)
		queue_free()

#func chase(body: Node2D) -> void:
	## Change target point to be the player's area2d child
	#target_point = body.get_child(2)

#When player is inside the Attack Area, Take Damage (Will be change to something more later)
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		attack_player = true
		player.reduce_player_health(damage)
		timer.start()

func _on_detection_body_entered(body: Node2D) -> void:
	# If player enters cone of detection, chase the player
	if body.name == "Player":
		attack_player = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	# When player escapes, don't reduce health anymore
	if body.name == "Player":
		attack_player = false
			
func _on_attack_timer_timeout() -> void:
	# timer to allow player iframes
	if !player.stealth and attack_player:
		shoot_player()
	timer.start()

func _on_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		attack_player = false
