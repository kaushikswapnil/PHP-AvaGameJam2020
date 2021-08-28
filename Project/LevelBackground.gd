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
		material.set_shader_param("portal_position", m_PortalUVPositions[0])
		material.set_shader_param("portal_direction", m_PortalDirections[0])
		
		m_PortalDirections[0] = Vector2(cos(m_TotalDelta), sin(m_TotalDelta))
		
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

