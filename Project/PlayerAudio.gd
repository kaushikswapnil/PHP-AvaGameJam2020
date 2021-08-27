extends AudioStreamPlayer

func _ready():
	pass # Replace with function body.

func _on_Player_s_PlayAudio(audio_res):
	set_stream(audio_res)
	play()
