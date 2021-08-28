extends Area2D

class_name Weapon

signal OnDamageInflicted(damage, to_body)

export var OnHitDamage : int

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var m_ComboCounter = 0

func IncrementComboCounter():
	m_ComboCounter += 1
	
func ResetComboCounter():
	m_ComboCounter = 0

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
		emit_signal("OnDamageInflicted", OnHitDamage, body)
		
func IsCollidable():
	return monitorable && monitoring
