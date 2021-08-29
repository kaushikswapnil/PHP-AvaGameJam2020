extends Node2D

export var PlayerRes : PackedScene

onready var m_Players = []

onready var m_Started = false

func _ready():
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")	
	
func _process(delta):
	for player in m_Players:
		for portal_pos in $LevelBackground.m_PortalWorldPositions:
			var player_to_portal = portal_pos - player.global_position
			if (player_to_portal.length() <= $LevelBackground.m_PortalWorldWidth):
				ResetLevel(true)
		
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
	ResetLevel(false)
	#AddPlayer(-1, false, Color(0, 0, 0))
	var connected_pads = Input.get_connected_joypads()
	if (connected_pads.size() == 2):
		AddPlayer(connected_pads[0], true, Color(0.0, 0.0, 0.0, 1.0))
		AddPlayer(connected_pads[1], true, Color(1.0, 1.0, 1.0, 1.0))
	elif (connected_pads.size() == 1):
		AddPlayer(connected_pads[0], true, Color(0.0, 0.0, 0.0, 1.0))
	m_Started = true
	
func QuitGame():
	get_tree().quit()
	
func ResetLevel(respawn_players):
	$Menu.visible = false
	ClearAllPlatforms()
	var screen_size = get_viewport().get_visible_rect().size
	var rng = RandomNumberGenerator.new()
	rng.seed = OS.get_time().second
	var num_portals = 1#rng.randi_range(1, 4)
	$LevelBackground.Reset()
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
			portal_pos.y  = rng.randf_range(-screen_size.y, -screen_size.y * 0.5)
		$LevelBackground.AddPortal(portal_pos)
	$LevelBackground.init($Camera2D.global_position)
	$BackGroundMusicPlayer.play()
	
	if respawn_players:
		for p in m_Players:
			p.global_position = $DefaultSpawnPosition.position + Vector2(rand_range(-2.0, 2.0), rand_range(-2.0, 2.0))

func _input(event):
	if (!m_Started && (event.is_action_pressed("jump") || event.is_action_pressed("ui_accept"))):
		StartGame()
	elif (m_Started && (event.is_action_pressed("ui_end"))):
		QuitGame()
		
onready var m_Platforms = []
func AddPlatformAt(global_pos, modulate_col, collision_m, collision_l, platform_res):
	var new_platform = platform_res.instance()
	add_child(new_platform)
	m_Platforms.append(new_platform)
	new_platform.position = global_pos
	#new_platform.rotation_degrees = rotation_degree
	new_platform.set_modulate(modulate_col)
	new_platform.collision_layer = collision_l
	new_platform.collision_mask = collision_m

func ClearAllPlatforms():
	for p in m_Platforms:
		remove_child(p)
		p.queue_free()
	m_Platforms.clear()
