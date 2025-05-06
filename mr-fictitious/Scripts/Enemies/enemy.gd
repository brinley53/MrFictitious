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
	Brinley Hull - 4/21/2025: Better Navigation
	Brinley Hull - 4/22/2025: Darting Rats
	Jose Leyba  - 4/24/2025: Stun Function
	Brinley Hull - 4/26/2025: Ranged Enemy
	Brinley Hull - 5/1/2025: Knockback
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
@export var patrol_a : Area2D
@export var patrol_b : Area2D
@export var disabled : bool
@export var flipped : bool
var current_proc_count = 0

var target_point:Node2D
var point_a = 0
var point_b = 0

var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_strength := 600.0
var knockback_decay := 2000.0

#chase player variables
var chase_player = false
var attack_player = false
var poison = false
var stand = false
var stunned = false
var current_stun_timer: Timer = null
const BULLET_SCENE = preload("res://Scenes/Enemies/shadow_bullet.tscn") 
# On ready attributes
@onready var timer = $AttackTimer
@onready var sprite = $AnimatedSprite2D
@onready var detection = $Detection
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]
@onready var nav_timer = $NavTimer
@onready var nav_agent = $NavigationAgent2D

var shot_timer:Timer

#Griffin specs
var vulnerable_area:Area2D
var spec_timer:Timer
var statue = true

var patrol_points
var dart_timer:Timer
@export_enum("Wolf", "Rat", "Worker", "Ranged", "Griffin") var type : String


func _ready():
	#set initial variables
	patrol_points = get_tree().get_nodes_in_group("Patrol")
	if patrol_a == null or patrol_b == null:
		if len(patrol_points) > 1:
			point_a = randi_range(0, len(patrol_points)-1)
			point_b = randi_range(0, len(patrol_points)-1)
			while point_b == point_a:
				point_b = randi_range(0, len(patrol_points)-1)
			target_point = patrol_points[point_a]
		else:
			target_point = player
	else:
		target_point = patrol_a
	speed = base_speed
	if type=="Rat":
		dart_timer = $DartTimer
		dart_timer.start()
	if type=="Ranged":
		shot_timer = $ShotTimer
		
	if type == "Griffin":
		vulnerable_area = $Vulnerable
		spec_timer = $SpecTimer
		
	sprite.flip_h = flipped
	
func reset_patrol():
	if patrol_a == null or patrol_b == null:
		if len(patrol_points) < 2:
			target_point = player
		else:
			target_point = patrol_points[point_a]
	else:
		target_point = patrol_a
	chase_player = false
	speed = base_speed
	attack_player = false

func _physics_process(delta: float) -> void:
	if stunned or disabled:
		if type=="Rat":
			sprite.play("stand")
		return
	if player.stealth and chase_player:
		reset_patrol()
		
	if knockback_velocity.length() > 0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
		move_and_slide()
		return
		
	if type=="Rat":
		if stand:
			sprite.play("stand")
		else:
			chase(target_point)
	elif type=="Griffin":
		if !statue:
			chase(target_point)
		else:
			sprite.pause()
	else:
		chase(target_point)
		
	if chase_player:
		target_point = player
		
	check_patrol()
	
func shoot_player():
	var bullet = BULLET_SCENE.instantiate()
	bullet.body_entered.connect(bullet._on_body_entered)
	bullet.global_position = global_position
	bullet.initialize_bullet(player.global_position)
	get_parent().add_child(bullet)
	
func check_patrol():
	#if we're close to the target point, change patrol points as the target point
	if global_position.distance_to(target_point.global_position) < $CollisionShape2D.shape.radius and !chase_player and len(patrol_points) > 1:
		# Swap target between point A and B
		if patrol_a == null or patrol_b == null:
			target_point = patrol_points[point_a] if target_point == patrol_points[point_b] else patrol_points[point_b]
		else:
			target_point = patrol_a if target_point == patrol_b else patrol_b
		if type == "Rat":
			point_a = randi_range(0, len(patrol_points)-1)
			point_b = randi_range(0, len(patrol_points)-1)
			while point_b == point_a:
				point_b = randi_range(0, len(patrol_points)-1)
		
	if target_point == null and len(patrol_points) > 1:
		reset_patrol()

#When player is inside the Attack Area, Take Damage (Will be change to something more later)
func _on_attack_area_body_entered(body: Node2D) -> void:
	timer.start()
	if disabled:
		return
	if body.name == "Player":
		attack_player = true
		player.initiate_combat()
		player.reduce_player_health(damage)

#Takes damage, when life reaches 0 it dies
func reduce_enemy_health(damage_dealt):
	if disabled:
		return
	chase_player = true
	player.initiate_combat()
	if type == "Griffin":
		var vulnerable_areas = vulnerable_area.get_overlapping_areas()
		var vulnerable = false
		for area in vulnerable_areas:
			if area.is_in_group("Weapon"):
				vulnerable = true
		if !vulnerable:
			return
	health = health - damage_dealt
	if health <= 0:
		var loot_options = [bullet_scene, bullet_scene, bullet_scene, bullet_scene, health_scene]
		var num_loot = randi_range(1, 3)
		for i in range(num_loot):
			var item_scene = loot_options[randi() % loot_options.size()]
			var item = item_scene.instantiate()
			var manager = get_node("/root/Main/RoomManager")
			var room = manager.get_active_room()
			room.add_child(item)
			var angle = randf() * TAU 
			var radius = randf_range(64.0, 128.0)
			var offset = Vector2(cos(angle), sin(angle)) * radius
			item.global_position = global_position + offset
		queue_free()


func _on_detection_body_entered(body: Node2D) -> void:
	# If player enters cone of detection, chase the player
	if body.name == "Player":
		if !body.stealth:
			player.initiate_combat()
			chase_player = true
			if type=="Ranged":
				shot_timer.start()
		
func chase(body: Node2D) -> void:
	# Change target point
	nav_agent.target_position = body.global_position
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	
	# change sprite
	if chase_player:
		sprite.play("run")
		if (type == "Wolf" or type == "Griffin"):
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

func _on_attack_area_body_exited(body: Node2D) -> void:
	# When player escapes, don't reduce health anymore
	if body.name == "Player":
		attack_player = false
		if (type == 'Wolf'):
			player.poison(poison_proc_count, damage)			

func _on_attack_timer_timeout() -> void:
	# timer to allow player iframes
	if attack_player:
		timer.start()
		if stunned or disabled:
			pass
		player.reduce_player_health(damage)

func _on_dart_timer_timeout() -> void:
	dart_timer.start()
	stand = !stand

func _on_nav_timer_timeout() -> void:
	pass # Replace with function body.


func _on_shot_timer_timeout() -> void:
	if chase_player:
		if stunned:
			pass
		shoot_player()
		shot_timer.start()

func knockback(pos):
	if disabled:
		return
	var direction = (global_position - pos).normalized()
	knockback_velocity = direction * knockback_strength

func _on_spec_timer_timeout() -> void:
	statue = !statue
	spec_timer.start()
