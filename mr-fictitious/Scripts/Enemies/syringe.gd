"""
Script for the syringes that Mendoza shoots
Authors: Brinley Hull, Jose Leyba
Creation Date: 04/28/2025
Revisions:
	Brinley Hull - 5/2/2025: Syringe liquids
"""

extends Area2D
var velocity = Vector2.ZERO  
var damage = 10
var poison_proc_count = 3
var debuff_duration = 3.0
var debuff_strength = 0.5
@onready var trail := $Trail
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]
var trail_points: Array[Vector2] = []
const MAX_POINTS = 4 
var type = "Poison"
var speed = 400
var target:Vector2

func _ready():
	trail.clear_points()
	trail_points.clear()
	speed = 500

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
		if type == "Poison":
			body.poison(poison_proc_count, damage/2)
		elif type == "Snail":
			body.apply_speed_buff(debuff_strength, debuff_duration)
		elif type == "Weak":
			body.apply_damage_buff(debuff_strength, debuff_duration)
		queue_free()

#Bullet disappears if nothing is hit in 4 seconds
func _on_timer_timeout() -> void:
	queue_free()
	
func initialize_bullet(target_position: Vector2, type_str="Poison") -> void:
	type = type_str
	target = target_position
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	rotation = direction.angle()
	if type == "Snail":
		$Weak.visible = false
		$Poison.visible = false
	elif type == "Weak":
		$Poison.visible = false
