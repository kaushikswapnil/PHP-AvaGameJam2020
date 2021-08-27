extends Node2D

export var PlayerRes : PackedScene

var m_Players = []

func _ready():
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	m_Players = []
	AddPlayer(0, false, Color(0, 0, 0))
	var connected_pads = Input.get_connected_joypads()
	for x in connected_pads:
		AddPlayer(x, true, Color(rand_range(0.0, 1.0), rand_range(0.0, 1.0), rand_range(0.0, 1.0)))
		

func _on_joy_connection_changed(device_id, connected):
	if (connected):
		var col = Color(1, 1, 1)
		if (m_Players.size() > 2):
			col = Color(rand_range(0.0, 1.0), rand_range(0.0, 1.0), rand_range(0.0, 1.0))
		AddPlayer(device_id, true, col)
	else:
		RemovePlayer(device_id)
		
func AddPlayer(device, randomize_pos, color):
	var new_player = PlayerRes.instance()
	m_Players.append(new_player)
	add_child(new_player)
	if randomize_pos:
		new_player.global_position = $DefaultSpawnPosition.position + Vector2(rand_range(-2.0, 2.0), rand_range(-2.0, 2.0))
	else:
		new_player.global_position = $DefaultSpawnPosition.position
	new_player.init(device, color)
	
func RemovePlayer(device):
	for p in m_Players:
		if (p.m_OwnedDevice == device):
			remove_child(p)
			m_Players.remove(p)
			break
