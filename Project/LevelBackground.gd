extends Sprite

onready var m_PortalUVPositions = []
onready var m_PortalDirections = []
onready var m_PortalWorldPositions = []

onready var m_TotalDelta = 0.0

onready var m_LightSource = Vector2(0.0, 0.0)

func _ready():
	pass # Replace with function body.
	
func _process(delta):
	if (m_PortalUVPositions.size() > 0):
		SetVariableShaderParameters()
		
		m_PortalDirections[0] = Vector2(cos(m_TotalDelta), sin(m_TotalDelta))
		for i in range(1, m_PortalDirections.size()):
			m_PortalDirections[i] = m_PortalDirections[0]
		
	m_TotalDelta += delta
	
func AddLightSource(light_world_pos):
	m_LightSource = light_world_pos

func AddPortal(portal_pos):
	m_PortalWorldPositions.append(portal_pos)
	var rand_angle = rand_range(0.0, 3.14)
	m_PortalDirections.append(Vector2(cos(rand_angle), sin(rand_angle)))
	var screen_size = get_viewport().get_visible_rect().size
	var portal_uv_position = Vector2(portal_pos.x/screen_size.x, 1.0 + (portal_pos.y/screen_size.y))
	print(portal_uv_position)
	m_PortalUVPositions.append(portal_uv_position)
	
	SetAllShaderParameters()
	
func SetAllShaderParameters():
	material.set_shader_param("num_portals", m_PortalUVPositions.size())
	
	if (m_PortalUVPositions.size() > 0):
		material.set_shader_param("portal_position_1", m_PortalUVPositions[0])
		material.set_shader_param("portal_direction_1", m_PortalDirections[0])
	if (m_PortalUVPositions.size() > 1):
		material.set_shader_param("portal_position_2", m_PortalUVPositions[1])
		material.set_shader_param("portal_direction_2", m_PortalDirections[1])
	if (m_PortalUVPositions.size() > 2):
		material.set_shader_param("portal_position_3", m_PortalUVPositions[2])
		material.set_shader_param("portal_direction_3", m_PortalDirections[2])
	if (m_PortalUVPositions.size() > 3):
		material.set_shader_param("portal_position_4", m_PortalUVPositions[3])
		material.set_shader_param("portal_direction_4", m_PortalDirections[3])
		
func SetVariableShaderParameters():
	if (m_PortalUVPositions.size() > 0):
		material.set_shader_param("portal_position_1", m_PortalUVPositions[0])
		material.set_shader_param("portal_direction_1", m_PortalDirections[0])
	if (m_PortalUVPositions.size() > 1):
		material.set_shader_param("portal_position_2", m_PortalUVPositions[1])
		material.set_shader_param("portal_direction_2", m_PortalDirections[1])
	if (m_PortalUVPositions.size() > 2):
		material.set_shader_param("portal_position_3", m_PortalUVPositions[2])
		material.set_shader_param("portal_direction_3", m_PortalDirections[2])
	if (m_PortalUVPositions.size() > 3):
		material.set_shader_param("portal_position_4", m_PortalUVPositions[3])
		material.set_shader_param("portal_direction_4", m_PortalDirections[3])

