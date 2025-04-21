"""
Script for the shadow bullets the crypt bos shoots
Authors: Brinley Hull, Jose Leyba
Creation Date: 04/17/2025
Revisions:
"""

extends Area2D
var velocity = Vector2.ZERO  
var damage = 100
@onready var trail := $Trail
var trail_points: Array[Vector2] = []
const MAX_POINTS = 4 

func _ready():
	trail.clear_points()
	trail_points.clear()

func _physics_process(delta):	
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
	queue_free()
	
func initialize_bullet(target_position: Vector2, speed: float) -> void:
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
