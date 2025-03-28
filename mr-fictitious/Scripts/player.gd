extends CharacterBody2D
#Player Area for attacks
@onready var attack_area = $AttackArea
const Speed = 300.0

func _process(delta):
	move_character(delta)
	if Input.is_action_just_pressed("attack"):
		attack()
	# Handle jump.
func move_character(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	
	if direction.length() > 0:
		direction = direction.normalized()
	
	velocity = direction * Speed
	move_and_slide()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
func attack():
	var mouse_position = get_global_mouse_position()
	var attack_direction = (mouse_position - global_position).normalized()
	var attack_angle = attack_direction.angle()
	attack_area.rotation = attack_angle  
