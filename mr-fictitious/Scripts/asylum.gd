'''
Script for the asylum boss room logic
Authors: Brinley Hull
Creation date: 4/29/2025
Revisions:
	Brinley Hull - 5/1/2025: Spawn workers
'''

extends Node2D

@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]
@onready var spawn = $Spawn
@onready var spawn_timer = $SpawnTimer
var spawning = false
const WORKER_SCENE = preload("res://Scenes/Enemies/asylum_worker.tscn")
const EVIDENCE_SCENE = preload("res://Scenes/evidence.tscn")  
var is_dead = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# call final boss dialogue
	await get_tree().process_frame  # Wait one frame so screen appears
	player.final_boss_dialogue()
	
func _physics_process(delta: float) -> void:
	if player.stealth and !spawning:
		spawn_workers()
		spawning = true
	
func spawn_workers():
	# Function to spawn workers
	if !player.stealth:
		spawning = false
		spawn_timer.stop()
		return
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	var worker = WORKER_SCENE.instantiate()
	worker.global_position = spawn.global_position
	var manager = get_node("/root/Main/RoomManager")
	var room = manager.get_active_room()
	room.add_child(worker)
	spawn_workers()


func _on_mendoza_dead() -> void:
	if is_dead:
		return
	call_deferred("_handle_death")

func _handle_death() -> void:
	if is_dead:
		return
	is_dead = true
	$BottomBorder/PathBlocker.queue_free()
	var item = EVIDENCE_SCENE.instantiate()
	item.global_position = Vector2(960, 540)
	var manager = get_node("/root/Main/RoomManager")
	var room = manager.get_active_room()
	room.add_child(item)
