extends KinematicBody2D

class_name Player

const PhysicsG = preload("res://physics_globals.gd")

var m_Velocity = Vector2(0, 0)
var m_DesiredDirection = Vector2(0, 0)

enum STATES { IDLE, NAVIGATION, JUMP, ATTACK, BLOCK, HURT, FALLING, DEAD }
var m_State = STATES.IDLE
var m_DesiredState = STATES.IDLE
var m_PreviousState = m_State
var m_TimeSinceLastStateChange = 0.0

var m_FacingRight = true
var m_IsOnGround = false

var m_CanFire = true

const JUMP_TIME = 1.2

export var PlatformRes : PackedScene

func init(device):
	m_OwnedDevice = device

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var desired_velocity = m_Velocity
	if (desired_velocity.y < PhysicsG.MAX_FALL_SPEED && m_State != STATES.JUMP):
		desired_velocity += PhysicsG.GRAVITY_VEC
		
	if (m_DesiredDirection.length() > 0):
		#add navigational velocity
		if (m_State == STATES.NAVIGATION):
			if (abs(m_Velocity.x) < PhysicsG.MAX_SPEED):
				desired_velocity += m_DesiredDirection * min(1.0, PhysicsG.MAX_SPEED - abs(desired_velocity.x))
		if (m_State == STATES.JUMP):
			if (abs(m_Velocity.x) < PhysicsG.MAX_SPEED):
				desired_velocity += m_DesiredDirection * min(0.5, PhysicsG.MAX_SPEED - abs(desired_velocity.x))
			desired_velocity.y -= (2.0 - m_TimeSinceLastStateChange/JUMP_TIME) * 1.0
	elif (m_Velocity.x > 0.0 && m_IsOnGround):
		if (abs(m_Velocity.x) < 0.01):
			m_Velocity = 0.0
		else:
			m_Velocity.x *= 0.5 #friction dampener			
		
	m_Velocity = move_and_slide(desired_velocity, PhysicsG.UP)
	m_IsOnGround = m_Velocity.y == 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ParseInput()
	Statemachine_Process(delta)
	UpdateRender(delta)
	
###########################################
# statemachine

func Statemachine_Process(delta):
	m_TimeSinceLastStateChange += delta
	match m_State:
		STATES.IDLE:
			SM_Idle(delta)
		STATES.NAVIGATION:
			SM_Navigation(delta)
		STATES.JUMP:
			SM_Jump(delta)
		STATES.ATTACK:
			SM_Attack(delta)
		STATES.BLOCK:
			SM_Block(delta)
		STATES.HURT:
			SM_Hurt(delta)
		STATES.FALLING:
			SM_FALLING(delta)
		STATES.DEAD:
			SM_Dead(delta)
		_:
			print("Something is wrong, I can feel it")

func SM_Transition(to_state):
	m_PreviousState = m_State
	m_State = to_state
	m_TimeSinceLastStateChange = 0
	
	match m_State:
		STATES.ATTACK:
			SM_Attack_OnEnter()
		STATES.IDLE:
			SM_Idle_OnEnter()
	
	print("Transitioning to state ", m_State)
	
func SM_HasPendingTransition():
	return m_DesiredState != m_State
	
func SM_TransitionIfAny(to_state):
	if (SM_HasPendingTransition()):
		SM_Transition(m_DesiredState)
	
func SM_Idle(delta):
	print("Player : Idle")
	if (!m_IsOnGround):
		m_DesiredState = STATES.FALLING
	SM_TransitionIfAny(m_DesiredState)

func SM_Idle_OnEnter():
	$AnimationPlayer.play("player_idle")
	
func SM_Navigation(delta):
	print("Player : Navigation")
	if (m_DesiredDirection.length() == 0.0 && m_Velocity.length() < 0.1):
		m_Velocity = Vector2(0.0, 0.0)
		m_DesiredState = STATES.IDLE
	SM_TransitionIfAny(m_DesiredState)
	
func SM_Jump(delta):
	print("Player : Jump")
	m_DesiredDirection = PhysicsG.UP
	if (m_TimeSinceLastStateChange >= JUMP_TIME):
		m_DesiredState = STATES.FALLING
	SM_TransitionIfAny(m_DesiredState)
	
func SM_Block(delta):
	print("Player : Block")
	SM_TransitionIfAny(m_DesiredState)
	
func SM_Hurt(delta):
	print("Player : Hurt")
	SM_TransitionIfAny(m_DesiredState)
	
func SM_FALLING(delta):
	print("Player : Falling")
	if (!SM_HasPendingTransition() && m_IsOnGround):
		m_DesiredState = STATES.IDLE
	SM_TransitionIfAny(m_DesiredState)
	
func SM_Dead(delta):
	print("Player : Dead")
	SM_TransitionIfAny(m_DesiredState)
	
	
func SM_Attack(delta):
	print("Player : Attack")
	if(m_TimeSinceLastStateChange > 10.0):
		m_DesiredState = STATES.IDLE	
	SM_TransitionIfAny(m_DesiredState)
		
func SM_Attack_OnEnter():
	var new_platform_position = global_position + (m_DesiredDirection + Vector2(sign(m_DesiredDirection.x) * 3.0, -3.0))
	var new_platform = PlatformRes.instance()
	add_child(new_platform)
	new_platform.position = new_platform_position
		
	
###########################################
# input
#
onready var m_OwnedDevice = InvalidDevice
const InvalidDevice = -1

func _input(event):
	if (event.device != m_OwnedDevice || event is InputEventMouseButton || event is InputEventMouseMotion):
		return
		
	if (ParseAttackInput_E(event)):
		return 
	elif (ParseNavigationalInput_E(event)):
		return 
	return 

func ParseInput():
	if (m_OwnedDevice != InvalidDevice):
		return #Only parse input here if we dont own a device 
	
	if (ParseAttackInput()):
		return true
	elif (ParseNavigationalInput()):
		return true
	return false

func ParseNavigationalInput_E(event):
	if (event.is_action_pressed("jump") && m_IsOnGround):
		m_DesiredState = STATES.JUMP
		m_DesiredDirection = PhysicsG.UP
		print("Jump Act Pressed")
	elif (event.is_action_pressed("right")):
		m_DesiredState = STATES.NAVIGATION
		m_DesiredDirection = PhysicsG.RIGHT
		print("Right Act Pressed")
	elif (event.is_action_pressed("left")):
		m_DesiredState = STATES.NAVIGATION
		m_DesiredDirection = PhysicsG.LEFT
		print("Left Act Pressed")
	else:
		return false
	return true
	
func ParseAttackInput_E(event):
	if (event.is_action_pressed("attack")):
		m_DesiredState = STATES.ATTACK
		if (m_FacingRight):
			m_DesiredDirection = PhysicsG.RIGHT
		else:
			m_DesiredDirection = PhysicsG.LEFT
		print("Attack Act Pressed")
		return true
		
	return false
		
func ParseNavigationalInput():
	if (Input.is_action_pressed("jump") && m_IsOnGround):
		m_DesiredState = STATES.JUMP
		m_DesiredDirection = PhysicsG.UP
		print("Jump Act Pressed")
	elif (Input.is_action_pressed("right")):
		m_DesiredState = STATES.NAVIGATION
		m_DesiredDirection = PhysicsG.RIGHT
		print("Right Act Pressed")
	elif (Input.is_action_pressed("left")):
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
	
###########################################
# Render

func UpdateRender(delta):
	if (abs(m_Velocity.x) > 0):
		m_FacingRight = m_Velocity.x > 0
		
	if (m_FacingRight):
		$hip.scale.x *= -1.0


func _on_Timer_timeout():
	m_CanFire = true
	
###########################################
# Sound

