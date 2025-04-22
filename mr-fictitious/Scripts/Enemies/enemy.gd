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
	Jose Leyba - 4/21/2025: Enemies drop health and/or bullets when killed (randomly)
"""
extends CharacterBody2D
#GLOBAL VARIABLES
# stats attributes
@export var health : int
var speed : float
@export var base_speed : float
@export var damage : float
@export var poison_proc_count : int
@export var bullet_scene: PackedScene = preload("res://Scenes/bullet.tscn")
@export var health_scene: PackedScene = preload("res://Scenes/health_item.tscn")
var current_proc_count = 0

var target_point:Node2D
var point_a = 0
var point_b = 0

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
@onready var nav_timer = $NavTimer
@onready var nav_agent = $NavigationAgent2D
var patrol_points
var dart_timer:Timer
@export_enum("Wolf", "Rat", "Poison") var type : String


func _ready():
	#set initial variables
	patrol_points = get_tree().get_nodes_in_group("Patrol")
	if len(patrol_points) != 0:
		point_a = randi_range(0, len(patrol_points)-1)
		point_b = randi_range(0, len(patrol_points)-1)
		while point_b == point_a:
			point_b = randi_range(0, len(patrol_points)-1)
		target_point = patrol_points[point_a]
	else:
		target_point = player
	speed = base_speed
	if type=="Rat":
		dart_timer = $DartTimer
	
func reset_patrol():
	if len(patrol_points) == 0:
		target_point = player
	else:
		target_point = patrol_points[point_a]
	chase_player = false
	speed = base_speed
	attack_player = false

func _physics_process(delta: float) -> void:
	if player.stealth and chase_player:
		reset_patrol()
		
	chase(target_point)
		
	if chase_player:
		target_point = player
		
	check_patrol()
	
func check_patrol():
	#if we're close to the target point, change patrol points as the target point
	if global_position.distance_to(target_point.global_position) < $CollisionShape2D.shape.radius and !chase_player and len(patrol_points) > 0:
		# Swap target between point A and B
		target_point = patrol_points[point_a] if target_point == patrol_points[point_b] else patrol_points[point_b]
		
	if target_point == null and len(patrol_points) > 0:
		target_point = point_a
		chase_player = false

#When player is inside the Attack Area, Take Damage (Will be change to something more later)
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		attack_player = true
		player.initiate_combat()
		player.reduce_player_health(damage)
		timer.start()

#Takes damage, when life reaches 0 it dies
func reduce_enemy_health(damage_dealt):
	health = health - damage_dealt
	chase_player = true
	player.initiate_combat()
	if health <= 0:
		var loot_options = [bullet_scene, health_scene]
		var num_loot = randi_range(0, 1)
		for i in range(num_loot):
			var item_scene = loot_options[randi() % loot_options.size()]
			var item = item_scene.instantiate()
			var angle = randf() * TAU 
			var radius = randf_range(64.0, 128.0)
			var offset = Vector2(cos(angle), sin(angle)) * radius
			item.global_position = global_position + offset
			get_tree().current_scene.add_child(item)
		queue_free()


func _on_detection_body_entered(body: Node2D) -> void:
	# If player enters cone of detection, chase the player
	if body.name == "Player":
		if !body.stealth:
			player.initiate_combat()
			chase_player = true
		
func chase(body: Node2D) -> void:
	# Change target point
	nav_agent.target_position = body.global_position
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	
	# change sprite
	if chase_player:
		sprite.play("run")
		if (type == "Wolf"):
			speed = base_speed * 2.5
	else:
		sprite.play("walk")
		speed = base_speed
			
	velocity = dir * speed
	
	# face the sprite and detection cone based on what direction we're going
	if dir.x > 0:
		sprite.flip_h = 0
	else:
		sprite.flip_h = 1
		
	if velocity.length() > 0:
		detection.rotation = velocity.angle()
	
	move_and_slide()
	

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

func _on_dart_timer_timeout() -> void:
	dart_timer.start()


func _on_nav_timer_timeout() -> void:
	pass # Replace with function body.
