"""
Script focused on the bullets the player can shoot
Authors: Jose Leyba
Creation Date: 04/03/2025
Revisions:
	Brinley Hull - 4/24/2025: Disappear on hit enemy
	Brinley Hull - 4/27/2025: Update statue boss bullet hit logic
"""

extends Node2D
var velocity = Vector2.ZERO  
@onready var trail := $Trail
var trail_points: Array[Vector2] = []
const MAX_POINTS = 4


func _ready():
	trail.clear_points()
	trail_points.clear()

#When it moves, leaves a trail behind
func _physics_process(delta):	
	position += velocity * delta
	trail_points.insert(0, global_position)
	if trail_points.size() > MAX_POINTS:
		trail_points = trail_points.slice(0, MAX_POINTS)
	trail.clear_points()
	for point in trail_points:
		trail.add_point(to_local(point))

# Deals damage to enemy when hit


#Bullet dissapear if nothing is hit in 4 seconds


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


func _on_timer_timeout() -> void:
	queue_free()
