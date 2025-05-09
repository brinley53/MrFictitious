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
var damage = 10
@onready var trail := $Trail
@export var btype = "None"

var trail_points: Array[Vector2] = []
const MAX_POINTS = 4 
var type = "Target"
var speed = 400
var target:Vector2
@onready var explosion_area = $Explosion
@onready var split_timer = $SplitTimer
const BULLET_SCENE = preload("res://Scenes/musket_projectile.tscn")  

func _ready():
	trail.clear_points()
	trail_points.clear()
	speed = 400
	split_timer.start()

func _physics_process(delta):	
	position += velocity * delta
	trail_points.insert(0, global_position)
	if trail_points.size() > MAX_POINTS:
		trail_points = trail_points.slice(0, MAX_POINTS)
	trail.clear_points()
	for point in trail_points:
		trail.add_point(to_local(point))

# Deals damage to enemies when hit
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		if body.has_method("reduce_enemy_health"):
			body.reduce_enemy_health(10)
			if body.has_method("knockback"):
				body.knockback(global_position)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	# attacking statue boss wings and head
	var body = area.get_parent()
	if body.name == "Statue" and area.name in ["LeftWing", "RightWing", "Head"] or area.name == "Vulnerable":
		if area.name == "Vulnerable":
			body = body.get_parent()
			if body.has_method("knockback"):
				body.knockback(global_position)
		if body.has_method("reduce_enemy_health"):
			body.reduce_enemy_health(10, area.name)
		queue_free()
		

#Bullet disappears if nothing is hit in 4 seconds
func _on_timer_timeout() -> void:
	# bullet explodes if time has passed
	if btype == "Mini":
		pass
	var bodies = explosion_area.get_overlapping_bodies()
	var areas = explosion_area.get_overlapping_areas()
	for body in bodies:
		if body.is_in_group("Enemies"):
			body.reduce_enemy_health(5)
	for area in areas:
		var body = area.get_parent()
		if body.name == "Statue" and area.name in ["LeftWing", "RightWing", "Head"] or area.name == "Vulnerable":
			if area.name == "Vulnerable":
				body = body.get_parent()
				if body.has_method("knockback"):
					body.knockback(global_position)
			if body.has_method("reduce_enemy_health"):
				body.reduce_enemy_health(10, area.name)
	queue_free()


func create_mini_bullet(velocity: Vector2):
	var bullet = BULLET_SCENE.instantiate()
	var manager = get_node("/root/Main/RoomManager")
	var room = manager.get_active_room()
	bullet.global_position = global_position
	bullet.initialize_velocity(velocity.normalized() * speed, "Mini")
	bullet.scale = Vector2(0.75, 0.75)
	room.add_child(bullet)

func _on_split_timer_timeout() -> void:
	if type == "Mini":
		return 

	create_mini_bullet(velocity)
	create_mini_bullet(velocity.rotated(deg_to_rad(20))) 
	create_mini_bullet(velocity.rotated(deg_to_rad(-20)))

	queue_free()

func initialize_velocity(vel: Vector2, type_str = "Default") -> void:
	type = type_str
	velocity = vel
	if type == "Mini":
		damage = damage / 2
