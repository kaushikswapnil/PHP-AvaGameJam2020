extends KinematicBody2D

const PhysicsG = preload("res://physics_globals.gd")

var m_Velocity = Vector2(0, 0)
var m_DesiredDirection = Vector2(0, 0)

enum STATES { IDLE, NAVIGATION, JUMP, ATTACK, BLOCK, HURT, FALLING, DEAD }
var m_State = STATES.IDLE
var m_DesiredState = STATES.IDLE
var m_TimeSinceLastStateChange = 0.0

var m_FacingRight = true

var frame_counter = 0;

func init():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	m_DesiredDirection = Vector2(0, 0)
	ParseInput()
	match m_State:
		STATES.IDLE:
			SM_Idle()
		STATES.NAVIGATION:
			SM_Navigation()
		STATES.JUMP:
			SM_Jump()
		STATES.ATTACK:
			SM_Attack()
		STATES.BLOCK:
			SM_Block()
		STATES.HURT:
			SM_Hurt()
		STATES.FALLING:
			SM_FALLING()
		STATES.DEAD:
			SM_Dead()
		_:
			print("Something is wrong, I can feel it")
	
# statemachine

func SM_Transition(to_state):
	m_State = to_state
	print("Transitioning to state ", m_State)
	
func SM_TransitionIfAny(to_state):
	if (m_DesiredState != m_State):
		SM_Transition(m_DesiredState)
	
func SM_Idle():
	print("Player : Idle")
	SM_TransitionIfAny(m_DesiredState)
func SM_Navigation():
	print("Player : Navigation")
	SM_TransitionIfAny(m_DesiredState)
func SM_Jump():
	print("Player : Jump")
	SM_TransitionIfAny(m_DesiredState)
func SM_Block():
	print("Player : Block")
	SM_TransitionIfAny(m_DesiredState)
func SM_Hurt():
	print("Player : Hurt")
	SM_TransitionIfAny(m_DesiredState)
func SM_FALLING():
	print("Player : Falling")
	SM_TransitionIfAny(m_DesiredState)
func SM_Dead():
	print("Player : Dead")
	SM_TransitionIfAny(m_DesiredState)
func SM_Attack():
	print("Player : Attack")
	SM_TransitionIfAny(m_DesiredState)
	
func ParseInput():
	if (ParseNavigationalInput()):
		return
	elif (ParseAttackInput()):
		return
	return 
		
func ParseNavigationalInput():
	if (Input.is_action_pressed("jump")):
		m_DesiredState = STATES.JUMP
		m_DesiredDirection = PhysicsG.UP
		print("Jump Act Pressed")
	elif (Input.is_action_just_pressed("right")):
		m_DesiredState = STATES.NAVIGATION
		m_DesiredDirection = PhysicsG.RIGHT
		print("Right Act Pressed")
	elif (Input.is_action_just_pressed("left")):
		m_DesiredState = STATES.NAVIGATION
		m_DesiredDirection = PhysicsG.LEFT
		print("Left Act Pressed")
	else:
		return false
	return true
	
func ParseAttackInput():
	if (Input.is_action_just_pressed("attack")):
		m_DesiredState = STATES.ATTACK
		if (m_FacingRight):
			m_DesiredDirection = PhysicsG.RIGHT
		else:
			m_DesiredDirection = PhysicsG.LEFT
		print("Attack Act Pressed")
		return true
		
	return false
		
