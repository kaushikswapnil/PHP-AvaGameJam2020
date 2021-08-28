extends Sprite

onready var m_Portals = []
onready var m_PortalDirections = []

onready var m_TotalDelta = 0.0

func _ready():
	pass # Replace with function body.
	
func _process(delta):
	if (m_Portals.size() > 0):
		material.set_shader_param("portal_position", m_Portals[0])
		material.set_shader_param("portal_direction", m_PortalDirections[0])
		
		m_PortalDirections[0] = Vector2(cos(m_TotalDelta), sin(m_TotalDelta))
		
	m_TotalDelta += delta

func AddPortal(portal_pos, portal_dir):
	m_Portals.append(portal_pos)
	m_PortalDirections.append(portal_dir)

