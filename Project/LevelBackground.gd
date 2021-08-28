extends Sprite

onready var m_PortalUVPositions = []
onready var m_PortalDirections = []
onready var m_PortalWorldPositions = []

onready var m_TotalDelta = 0.0

var m_CamPos = Vector2(0.0, 0.0)
onready var m_LightSourceRadi = 0.0

onready var m_PortalWorldWidth = 0.0
onready var m_PortalUVWidth = 0.03

func _ready():
	pass # Replace with function body.
	
func init(cam_pos):
	m_CamPos = cam_pos
	var screen_size = get_viewport().get_visible_rect().size
	m_PortalWorldWidth = screen_size.x * m_PortalUVWidth
	var max_radi = max(screen_size.x, screen_size.y) * 2.0
	m_LightSourceRadi = max_radi	
	
func Reset():
	m_PortalUVPositions.clear()
	m_PortalDirections.clear()
	m_PortalWorldPositions.clear()
	
func _process(delta):
	var light_source = m_CamPos + (m_LightSourceRadi * Vector2(cos(m_TotalDelta), sin(m_TotalDelta)))
	for i in range(m_PortalDirections.size()):
		var light_dir = m_PortalWorldPositions[i] - light_source
		light_dir = light_dir.normalized()
		m_PortalDirections[i] = light_dir	
	
	if (m_PortalUVPositions.size() > 0):
		SetVariableShaderParameters()
		
	m_TotalDelta += delta                            

func AddPortal(portal_pos):
	var screen_size = get_viewport().get_visible_rect().size
	m_PortalWorldPositions.append(portal_pos)
	var rand_angle = rand_range(0.0, 3.14)
	m_PortalDirections.append(Vector2(cos(rand_angle), sin(rand_angle)))
	var portal_uv_position = Vector2(portal_pos.x/screen_size.x, 1.0 + (portal_pos.y/screen_size.y))
	print(portal_uv_position)
	m_PortalUVPositions.append(portal_uv_position)
	
	SetAllShaderParameters()
	
func SetAllShaderParameters():
	material.set_shader_param("num_portals", m_PortalUVPositions.size())
	material.set_shader_param("portal_width", m_PortalUVWidth)
	
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

