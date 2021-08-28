extends Node2D

export var PlayerRes : PackedScene

onready var m_Players = []

onready var m_Started = false

func _ready():
	pass	
		
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
	new_player.init(device, color, m_Players.size() - 1)
	
func RemovePlayer(device):
	for p in range(m_Players.size()):
		if (m_Players[p].m_OwnedDevice == device):
			remove_child(m_Players[p])
			m_Players.remove(p)
			break

func _on_Menu_OnStartPressed():
	if (m_Started):
		return
	StartGame()
	
func _on_Menu_OnQuitPressed():
	QuitGame()
	
func StartGame():	
	$Menu.visible = false
	AddPlayer(-1, false, Color(0, 0, 0))
	var connected_pads = Input.get_connected_joypads()
	for x in connected_pads:
		AddPlayer(x, true, Color(rand_range(0.0, 1.0), rand_range(0.0, 1.0), rand_range(0.0, 1.0)))
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	m_Started = true
	
func QuitGame():
	get_tree().quit()

func _input(event):
	if (!m_Started && (event.is_action_pressed("jump") || event.is_action_pressed("ui_accept"))):
		StartGame()
	elif (m_Started && (event.is_action_pressed("ui_end"))):
		QuitGame()
