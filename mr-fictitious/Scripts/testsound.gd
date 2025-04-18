extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Wwise.register_game_obj(self,self.name)
	Wwise.register_listener(self)
	Wwise.load_bank_id(AK.BANKS.MUSIC)
	Wwise.load_bank_id(AK.BANKS.SOUND)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Sound1"):
		Wwise.post_event_id(AK.EVENTS.PLAYMUSIC,self)
		Wwise.post_event_id(AK.EVENTS.FOREST,self)
		Wwise.post_event_id(AK.EVENTS.EXPLORE,self)
	
	if Input.is_action_just_pressed("Sound2"):
		Wwise.post_event_id(AK.EVENTS.PLAYMUSIC,self)
		Wwise.post_event_id(AK.EVENTS.CAMP,self)
		Wwise.post_event_id(AK.EVENTS.EXPLORE,self)
	
	if Input.is_action_just_pressed("Sound3"):
		Wwise.post_event_id(AK.EVENTS.PLAYER_GUN_SHOOT,self)
		
		
