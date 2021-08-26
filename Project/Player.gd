extends KinematicBody2D

const PhysicsG = preload("res://physics_globals.gd")

var m_Velocity = Vector2(0, 0)
var m_DesiredDirection = Vector2(0, 0)

enum STATE_FLAGS { IDLE, NAVIGATION, JUMP, ATTACK, BLOCK, HURT, FALLING, DEAD }
var m_State = STATE_FLAGS.IDLE
var m_DesiredState = STATE_FLAGS.IDLE
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
	ParseInput()
	
# statemachine

func SM_Idle():
	pass
func SM_Navigation():
	pass
func SM_Jump():
	pass
func SM_Block():
	pass
func SM_Hurt():
	pass
func SM_FALLING():
	pass
func SM_Dead():
	pass
func SM_Attack():
	pass
	
func ParseInput():
	if (ParseNavigationalInput()):
		return
	elif (ParseAttackInput()):
		return
	return 
		
func ParseNavigationalInput():
	if (Input.is_action_pressed("jump")):
		m_DesiredState = STATE_FLAGS.JUMP
		m_DesiredDirection = PhysicsG.UP
		print("Jump Act Pressed")
	elif (Input.is_action_just_pressed("right")):
		m_DesiredState = STATE_FLAGS.NAVIGATION
		m_DesiredDirection = PhysicsG.RIGHT
		print("Right Act Pressed")
	elif (Input.is_action_just_pressed("left")):
		m_DesiredState = STATE_FLAGS.NAVIGATION
		m_DesiredDirection = PhysicsG.LEFT
		print("Left Act Pressed")
	else:
		return false
	return true
	
func ParseAttackInput():
	if (Input.is_action_just_pressed("attack")):
		m_DesiredState = STATE_FLAGS.ATTACK
		if (m_FacingRight):
			m_DesiredDirection = PhysicsG.RIGHT
		else:
			m_DesiredDirection = PhysicsG.LEFT
		print("Attack Act Pressed")
		return true
		
	return false
		
