extends Node2D

enum Audio { BACKGROUND, WALK, JUMP, ATTACK, BLOCK, HURT, FALL }

var AudioFiles = 
{
	Audio.BACKGROUND:"",
	Audio.WALK:"",
	Audio.JUMP:"",
	Audio.ATTACK:"",
	Audio.HURT:"",
	Audio.FALL:"",
}

var AudioStreams = {}

func _ready():
		
	
	
signal PlayAudio():
	

enum PLAYERSFX { PLAYER1, PLAYER2}


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
	
	var audio_clip : AudioStream = load(audio_file)
	match player:
		PLAYERSFX.PLAYER1:
			$SFX/Player1.stream = audio_clip
			$SFX/Player1.play()
		PLAYERSFX.PLAYER2:
			$SFX/Player2.stream = audio_clip
			$SFX/Player2.play()
	pass
	   
	

