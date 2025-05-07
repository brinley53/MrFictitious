extends Node2D
class_name TitleMusic
var title_music_is_playing:bool=false;
# Called when the node enters the scene tree for the first time.
func play_music(obj:Object):
	print(title_music_is_playing)
	if(!title_music_is_playing):
		Wwise.register_game_obj(obj,obj.name)
		Wwise.register_listener(obj)
		Wwise.load_bank_id(AK.BANKS.MUSIC)
		Wwise.load_bank_id(AK.BANKS.SOUND)
		Wwise.post_event_id(AK.EVENTS.PLAYMUSIC,obj)
		title_music_is_playing=true

func stop_music(obj:Object):
	title_music_is_playing=false
	Wwise.post_event_id(AK.EVENTS.MENU_CLICK,obj)
	Wwise.unregister_game_obj(obj)
	Wwise.unload_bank_id(AK.BANKS.SOUND)
	Wwise.unload_bank_id(AK.BANKS.MUSIC)

func play_loading_music():
	Wwise.post_event_id(AK.EVENTS.LOADING_START,self)

func stop_loading_music():
	Wwise.post_event_id(AK.EVENTS.LOADING_END,self)
