extends AnimationPlayer

func _ready():
	pass # Replace with function body.

func _on_Player_s_PlayAnimation(animation_track):
	play(animation_track)

func _on_Player_s_StopAnimation():
	if(is_playing()):
		stop()
