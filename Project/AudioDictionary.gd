extends Node2D
var AudioStreams = {
	"BACKGROUND" : AudioStream,
	"WALK" : AudioStream,
	"JUMP" : AudioStream,
	"SWORDCLASH": AudioStream,
	"SWORDSLASH": AudioStream,
	"HURT": AudioStream
}

func _ready():
	AudioStreams.BACKGROUND = load("res://res/Audio/BattleBackgroundMusic.ogg")
	AudioStreams.WALK = load("res://res/Audio/steps.ogg")
	AudioStreams.JUMP = load("res://res/Audio/jumpland.ogg")
	AudioStreams.SWORDCLAN = load("res://res/Audio/sword_clash.ogg")
	AudioStreams.SWORDSLASH = load("res://res/Audio/sword_slash.ogg")
	AudioStreams.HURT = load("res://res/Audio/hurt.ogg")
	

	
	   
	

