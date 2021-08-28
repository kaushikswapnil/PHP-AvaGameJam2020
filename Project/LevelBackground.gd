extends Sprite

onready var m_Portals = []
onready var m_PortalDirections = []

func _ready():
	pass # Replace with function body.
	
func _process(delta):
	if (m_Portals.size() > 0):
		material.set_shader_param("portal_position", m_Portals[0])
		material.set_shader_param("portal_direction", m_PortalDirections[0])

func AddPortal(portal_pos, portal_dir):
	m_Portals.append(portal_pos)
	m_PortalDirections.append(portal_dir)

