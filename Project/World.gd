extends Node2D

export var PlayerRes : PackedScene

onready var m_Players = []

onready var m_Started = false

func _ready():
	pass	
		
func _on_joy_connection_changed(device_id, connected):
	if (connected):
		if (m_Players.size() == 0):
			AddPlayer(device_id, true, Color(0.0, 0.0, 0.0, 1.0))
		elif (m_Players.size() == 1):
			AddPlayer(device_id, true, Color(1.0, 1.0, 1.0, 1.0))		
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
	var screen_size = get_viewport().get_visible_rect().size
	var rng = RandomNumberGenerator.new()
	rng.seed = OS.get_time().second
	var num_portals = rng.randi_range(1, 4)
	for x in range(num_portals):
		var portal_pos = Vector2(screen_size.x * 0.1, -screen_size.y)
		var randomize_x = rng.randf_range(0.0, 1.0) < 0.4
		if (randomize_x):
			portal_pos.x = rng.randf_range(0.0, screen_size.x)
		else:
			var rand = rng.randf_range(0.0, 1.0)
			if rand < 0.5:
				portal_pos.x = 0.0
			else:
				portal_pos.x = screen_size.x
			portal_pos.y  = rng.randf_range(-screen_size.y, 0.0)
		$LevelBackground.AddPortal(portal_pos)
	$BackGroundMusicPlayer.play()
	#AddPlayer(-1, false, Color(0, 0, 0))
	var connected_pads = Input.get_connected_joypads()
	if (connected_pads.size() == 2):
		AddPlayer(connected_pads[0], true, Color(0.0, 0.0, 0.0, 1.0))
		AddPlayer(connected_pads[1], true, Color(1.0, 1.0, 1.0, 1.0))
	elif (connected_pads.size() == 1):
		AddPlayer(connected_pads[0], true, Color(0.0, 0.0, 0.0, 1.0))
		#for x in connected_pads:
	#	AddPlayer(x, true, Color(rand_range(0.0, 1.0), rand_range(0.0, 1.0), rand_range(0.0, 1.0)))
		Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	m_Started = true
	
func QuitGame():
	get_tree().quit()

func _input(event):
	if (!m_Started && (event.is_action_pressed("jump") || event.is_action_pressed("ui_accept"))):
		StartGame()
	elif (m_Started && (event.is_action_pressed("ui_end"))):
		QuitGame()
