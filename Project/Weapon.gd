extends Area2D

class_name Weapon

export var OnHitDamage : int

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func ActivateCollisionDetection():
	monitorable = true
	monitoring = true

func DeactivateCollisionDetection():
	monitorable = false
	monitoring = false

func _on_Weapon_body_entered(body):
	if body is Player:
		body.OnDamage(OnHitDamage)
