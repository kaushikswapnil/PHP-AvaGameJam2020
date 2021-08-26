extends Node2D

enum PLAYERSFX { PLAYER1, PLAYER2}
enum STATES { WALK, JUMP, ATTACK, BLOCK, HURT, FALL }

func PlayMusic(music_clip: AudioStream):
	$Music/music_player.stream = music_clip
	$Music/music_player.play()
	pass
	
func PlaySFX( player,state):
	var audio_file = ""
	match state:
		STATES.WALK:
			audio_file = ""
		STATES.JUMP:
			audio_file = ""
		STATES.ATTACK:
			audio_file = "res://Resources/Audio/test.ogg"
		STATES.BLOCK:
			audio_file = ""
		STATES.HURT:
			audio_file = ""
		STATES.FALL:
			audio_file = ""
		_:
			audio_file = ""	
	
	var audio_clip : AudioStream = load("res://Resources/Audio/test.ogg")
	match player:
		PLAYERSFX.PLAYER1:
			$SFX/Player1.stream = audio_clip
			$SFX/Player1.play()
		PLAYERSFX.PLAYER2:
			$SFX/Player2.stream = audio_clip
			$SFX/Player2.play()
	pass
	   
	

