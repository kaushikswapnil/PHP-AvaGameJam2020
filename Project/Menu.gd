extends Control
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal OnStartPressed()
signal OnQuitPressed()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_start_button_pressed():
	emit_signal("OnStartPressed")


func _on_end_button_pressed():
	emit_signal("OnQuitPressed")
