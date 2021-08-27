extends Node2D

export var PlayerRes : PackedScene

var m_Players = []

func _ready():
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	m_Players = []
	AddPlayer(-1, false)

func _on_joy_connection_changed(device_id, connected):
	if (connected):
		AddPlayer(device_id, true)
	else:
		RemovePlayer(device_id)
		
func AddPlayer(device, randomize_pos):
	var new_player = PlayerRes.instance()
	m_Players.append(new_player)
	add_child(new_player)
	if randomize_pos:
		new_player.global_position = $DefaultSpawnPosition.position + Vector2(rand_range(-2.0, 2.0), rand_range(-2.0, 2.0))
	else:
		new_player.global_position = $DefaultSpawnPosition.position
	new_player.init(device)
	
func RemovePlayer(device):
	for p in m_Players:
		if (p.m_OwnedDevice == device):
			remove_child(p)
			m_Players.remove(p)
			break
