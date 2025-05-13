"""
Script for the shadow bullets the crypt boss shoots
Authors: Brinley Hull, Jose Leyba
Creation Date: 04/17/2025
Revisions:
	Brinley Hull - 4/23/2025: Create different types of bullets
	Brinley Hull - 4/25/2025: Change speed of target bullets
"""

extends Area2D
var velocity = Vector2.ZERO  
var base_damage = 10
var damage = base_damage
@onready var trail := $Trail
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]
var trail_points: Array[Vector2] = []
const MAX_POINTS = 4 
var type = "Target"
var speed = 400
var target:Vector2
@onready var explosion_area = $Explosion
@onready var split_timer = $SplitTimer
const BULLET_SCENE = preload("res://Scenes/Enemies/shadow_bullet.tscn")  

func _ready():
	trail.clear_points()
	trail_points.clear()
	if type == "Target":
		speed = 200
	else:
		speed = 400
	
	split_timer.start()

func _physics_process(delta):	
	if type == "Target":
		var direction = (player.global_position - global_position).normalized()
		velocity = direction*speed
	position += velocity * delta
	trail_points.insert(0, global_position)
	if trail_points.size() > MAX_POINTS:
		trail_points = trail_points.slice(0, MAX_POINTS)
	trail.clear_points()
	for point in trail_points:
		trail.add_point(to_local(point))

# Deals damage to player when hit
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.reduce_player_health(damage)
		queue_free()

#Bullet disappears if nothing is hit in 4 seconds
func _on_timer_timeout() -> void:
	# bullet explodes if time has passed
	var bodies = explosion_area.get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			player.reduce_player_health(damage * 0.5)
	queue_free()
	
func initialize_bullet(target_position: Vector2, type_str="Default") -> void:
	type = type_str
	target = target_position
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	damage = base_damage
	if type == "Mini":
		@warning_ignore("integer_division")
		damage = base_damage / 2
		
func create_mini_bullet(target_pos):
	# Function to create a mini bullet
	var bullet = BULLET_SCENE.instantiate()
	bullet.body_entered.connect(bullet._on_body_entered)
	bullet.global_position = global_position
	bullet.initialize_bullet(target_pos, "Mini")
	bullet.scale = Vector2(0.75, 0.75)
	get_parent().add_child(bullet)

func _on_split_timer_timeout() -> void:
	if type == "Split":
		#instantiate 3 more bullets to split the current bullet
		var to_bullet = (global_position - target).normalized()
		var angle_offset = deg_to_rad(45)
		# Slightly rotate left or right
		var left_offset = to_bullet.rotated(-angle_offset) * 100.0
		var right_offset = to_bullet.rotated(angle_offset) * 100.0
		create_mini_bullet(target + left_offset)
		create_mini_bullet(target)
		create_mini_bullet(target + right_offset)
		queue_free()
