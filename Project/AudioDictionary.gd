extends Node2D
var AudioStreams = {
	"BACKGROUND" : AudioStream,
	"WALK" : AudioStream,
	"JUMP" : AudioStream,
	"ATTACK": AudioStream,
	"BLOCK": AudioStream,
	"HURT": AudioStream
}

func _ready():
	AudioStreams.BACKGROUND = load("res://res/Audio/test.ogg")
	AudioStreams.WALK = load("res://res/Audio/test.ogg")
	AudioStreams.JUMP = load("res://res/Audio/test.ogg")
	AudioStreams.ATTACK = load("res://res/Audio/test.ogg")
	AudioStreams.BLOCK = load("res://res/Audio/test.ogg")
	AudioStreams.HURT = load("res://res/Audio/test.ogg")
	

	
	   
	

