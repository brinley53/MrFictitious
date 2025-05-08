"""
Script for the shadow crypt boss logic
Authors: Brinley Hull, Jose Leyba
Creation Date: 04/17/2025
Revisions:
		Jose Leyba - 04/21/2025: Boss drops the "key" (evidence) for final area when killed
		Brinley Hull - 4/22/2025: Boss movement and vulnerability
		Brinley Hull - 4/23/2025: Different boss attacks
		Jose Leyba - 4/24/2025: Stun functionality added
		Brinley Hull - 4/25/2025: Fix detection/attack areas
		Brinley Hull - 5/2/2025: Change boss style completely
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
var is_vulnerable = false
var attack = "Default"

#chase player variables
var chase_player = false
var attack_player = false
var dir_facing = 1
var stunned = false
var current_stun_timer: Timer = null
var prev_chase_player:bool = false
# On ready attributes
@onready var timer = $AttackTimer
@onready var sprite = $AnimatedSprite2D
@onready var detection = $Detection
@onready var vul_timer = $VulnerableTimer
@onready var vul_area = $VulnerableArea
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]
@onready var health_bar = $HealthContainer/HealthBar
@onready var attack_area = $AttackArea
@onready var melee_timer = $MeleeAttackTimer
@onready var shadow_area = $ShadowArea
@onready var detect_timer = $DetectTimer

# variable to control turning around on player hit
var detect = true


func _ready():
	#set initial variables
	await get_tree().process_frame
	speed = 30.0
	timer.start()
	health_bar.max_value = health
	health_bar.value = health
	Wwise.post_event_id(AK.EVENTS.HORSEMAN_ALERT,self)
	
func change_attack(attack_type):
	if stunned:
		return
	attack = attack_type
	
func shoot_player():
	if stunned:
		return
	Wwise.post_event_id(AK.EVENTS.HORSEMAN_SHOOT,self)
	var bullet = BULLET_SCENE.instantiate()
	bullet.body_entered.connect(bullet._on_body_entered)
	bullet.global_position = global_position
	bullet.initialize_bullet(player.global_position, attack)
	get_parent().add_child(bullet)

func _physics_process(delta: float) -> void:
	
	if stunned:
		return
	if (!player.stealth or (is_vulnerable and detect)) and chase_player:
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
		shadow_area.rotation = lerp_angle(detection.rotation, direction, delta)
		vul_area.scale.x = 1 if (player.global_position - global_position).normalized().x > 0 else -1
		var offset = Vector2(-67, 29)  # 67 pixels to the right
		offset.x *= vul_area.scale.x  # flip offset too
		vul_area.position = offset
		var attack_offset = Vector2(38, 5)
		attack_offset *= vul_area.scale.x
		attack_area.position = attack_offset
		
		velocity = (player.global_position - global_position).normalized() * speed
		move_and_slide()
		if(chase_player and !prev_chase_player):
			Wwise.post_event_id(AK.EVENTS.HORSEMAN_ALERT,self)
			prev_chase_player=true
		if(!chase_player and prev_chase_player):
			Wwise.post_event_id(AK.EVENTS.HORSEMAN_UNALERT,self)
			prev_chase_player=false
			

#Takes damage, when life reaches 0 it dies
func reduce_enemy_health(damage_dealt):
	if !is_vulnerable:
		return
	Wwise.post_event_id(AK.EVENTS.HORSEMAN_HURT,self)
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate=Color.WHITE
	health = health - damage_dealt
	health_bar.value = health
	if health <= 0:
		Wwise.post_event_id(AK.EVENTS.HORSEMAN_DEATH,self)
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
		melee_timer.start()

func _on_detection_body_entered(body: Node2D) -> void:
	# If player enters cone of detection, chase the player
	if stunned:
		return
	if body.name == "Player":
		chase_player = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	# When player escapes, don't reduce health anymore
	if body.name == "Player":
		attack_player = false
			
func _on_attack_timer_timeout() -> void:
	# timer to allow player iframes
	if stunned:
		return
	if (!player.stealth and chase_player and !is_vulnerable):
		shoot_player()
	timer.start()

func _on_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase_player = false

func _on_vulnerable_area_body_entered(body: Node2D) -> void:
	pass

func _on_vulnerable_timer_timeout() -> void:
	is_vulnerable = false
	
func _on_vulnerable_area_area_entered(area: Area2D) -> void:
	if !chase_player:
		detect = false
		detect_timer.start()
		is_vulnerable = true
		vul_timer.start()
		chase_player = true


func _on_melee_attack_timer_timeout() -> void:
	if attack_player:
		if stunned:
			pass
		player.reduce_player_health(damage)
		melee_timer.start()


func _on_detect_timer_timeout() -> void:
	detect = true
	detect_timer.stop()
