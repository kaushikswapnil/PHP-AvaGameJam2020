extends Area2D

class_name Weapon

signal OnDamageInflicted(damage, to_body)

export var OnHitDamage : int

var m_OwnerPlayer

func init(owner_player, col_mask):
	m_OwnerPlayer = owner_player
	collision_mask = col_mask

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
