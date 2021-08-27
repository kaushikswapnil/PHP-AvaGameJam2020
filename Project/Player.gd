extends KinematicBody2D

class_name Player

signal s_PlayAudio(audio_res)
signal s_PlayAnimation(animation_track)

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

func init(device, modulate_color):
	m_OwnedDevice = device
	$hip.set_modulate(modulate_color)

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
			if (abs(desired_velocity.x) < PhysicsG.MAX_SPEED):
				desired_velocity += m_DesiredDirection * min(0.5, PhysicsG.MAX_SPEED - abs(desired_velocity.x))
			desired_velocity.y -= (2.0 - m_TimeSinceLastStateChange/JUMP_TIME) * 1.0
	elif (abs(desired_velocity.x) > 0.0 && m_IsOnGround):
		if (abs(desired_velocity.x) < 0.01):
			desired_velocity = PhysicsG.NULL_VECTOR
		else:
			desired_velocity.x = max(0.0, abs(desired_velocity.x) - min(2.0, 0.5 * abs(desired_velocity.x))) * sign(desired_velocity.x)
		
	m_Velocity = move_and_slide(desired_velocity, PhysicsG.UP)
	m_IsOnGround = m_Velocity.y == 0
	m_FacingRight = m_Velocity.x > 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ParseInput(delta)
	Statemachine_Process(delta)
	UpdateRender(delta)
	
###########################################
# statemachine

func Statemachine_Process(delta):
	m_TimeSinceLastStateChange += delta
	
	if (m_Health < 0.0):
		m_DesiredState = STATES.DEAD
	elif m_PendingHurt:
		m_DesiredState = STATES.HURT
	
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
		STATES.NAVIGATION:
			SM_Navigation_OnEnter()
		STATES.JUMP:
			SM_Jump_OnEnter()
	
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
	emit_signal("s_PlayAnimation", "player_idle")
	
func SM_Navigation(delta):
	print("Player : Navigation")
	if (!m_InputsProcessedThisFrame && m_Velocity.length() < 0.01):
		m_Velocity = Vector2(0.0, 0.0)
		m_DesiredState = STATES.IDLE
	SM_TransitionIfAny(m_DesiredState)
	
func SM_Navigation_OnEnter():
	emit_signal("s_PlayAnimation", "player_walk")
	
func SM_Jump(delta):
	print("Player : Jump")
	m_DesiredDirection = PhysicsG.UP
	if (m_TimeSinceLastStateChange >= JUMP_TIME):
		m_DesiredState = STATES.FALLING
	SM_TransitionIfAny(m_DesiredState)
	
func SM_Jump_OnEnter():
	emit_signal("s_PlayAnimation", "player_jump")
	
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
	
var m_AttackCompleted = false
func SM_Attack(delta):
	print("Player : Attack")
	if(m_AttackCompleted):
		m_DesiredState = STATES.IDLE	
	SM_TransitionIfAny(m_DesiredState)
		
func SM_Attack_OnEnter():
	m_AttackCompleted = false
	if (m_DesiredDirection == PhysicsG.RIGHT):
		emit_signal("s_PlayAnimation", "player_attack_1")
	elif (m_DesiredDirection == PhysicsG.UP):
		emit_signal("s_PlayAnimation", "player_attack_2")
	elif (m_DesiredDirection == PhysicsG.DOWN):
		emit_signal("s_PlayAnimation", "player_attack_3")
	$PlayerAnimator.connect("animation_finished", self, "SM_OnAttackAnimation_Ended")
	
func SM_OnAttackAnimation_Ended(anim_name):
	m_AttackCompleted = true
	var facing = Vector2(1.0, 0.0)
	if !m_FacingRight:
		facing *= -1.0
	var new_platform_position = global_position
	var rotation_degree = rotation_degrees
	if anim_name == "player_attack_1":
		new_platform_position += (facing * 15.5) + Vector2(0.0, -3.5)
	elif anim_name == "player_attack_2":
		new_platform_position += (facing * 5.5) + Vector2(0.0, -12.0)
		rotation_degree += 45.0
	elif anim_name == "player_attack_3":
		new_platform_position += (facing * 3.5) + Vector2(0.0, 12.5)
		rotation_degree -= 45.0
	var new_platform = PlatformRes.instance()
	get_parent().add_child(new_platform)
	new_platform.position = new_platform_position
	new_platform.rotation_degrees = rotation_degree
	$PlayerAnimator.disconnect("animation_finished", self, "SM_OnAttackAnimation_Ended")
	
###########################################
# input
#
onready var m_OwnedDevice = InvalidDevice
const KeyBoard = -1
const InvalidDevice = -2
onready var m_TimeSinceLastInput = 0
onready var m_TimeSinceLastNavigationalInput = 0.0
onready var m_InputsProcessedThisFrame = false

onready var m_InputsToProcess = []

func _input(event):
	if (event is InputEventMouseButton || event is InputEventMouseMotion):
		return
	
	if (m_OwnedDevice == KeyBoard && !(event is InputEventKey)):
		return
		
	if (ParseAttackInput_E(event)):
		m_TimeSinceLastInput = 0 
	elif (ParseNavigationalInput_E(event)):
		m_TimeSinceLastInput = 0 
		m_TimeSinceLastNavigationalInput = 0
	return 

func ParseInput(delta):
	m_TimeSinceLastInput += delta
	m_TimeSinceLastNavigationalInput += delta
	m_InputsProcessedThisFrame = false
	
	if (m_OwnedDevice != InvalidDevice):
		if (m_InputsToProcess.size() > 0):
			var x = m_InputsToProcess.back()
			m_DesiredState = x[0]
			m_DesiredDirection = x[1]
			m_InputsToProcess.clear()
			m_InputsProcessedThisFrame = true
		else:
			m_DesiredState = m_State
			if (m_State != STATES.NAVIGATION):
				m_DesiredDirection = Vector2(0, 0)
		return #Only parse input here if we dont own a device 
	
	if (ParseAttackInput()):
		m_TimeSinceLastInput = 0
		m_InputsProcessedThisFrame = true
		return true
	elif (ParseNavigationalInput()):
		m_TimeSinceLastInput = 0
		m_TimeSinceLastNavigationalInput
		m_InputsProcessedThisFrame = true
		return true
	return false

func ParseNavigationalInput_E(event):
	if (m_IsOnGround):
		if (event.is_action_pressed("jump")):
			m_InputsToProcess.append([STATES.JUMP, PhysicsG.UP])
			print("Jump Act Pressed")
		elif (event.is_action_pressed("right")):
			m_InputsToProcess.append([STATES.NAVIGATION, PhysicsG.RIGHT])
			print("Right Act Pressed")
		elif (event.is_action_pressed("left")):
			m_InputsToProcess.append([STATES.NAVIGATION, PhysicsG.LEFT])
			print("Left Act Pressed")
		elif (m_State == STATES.NAVIGATION):
			if (event.is_action_released("right") || event.is_action_released("left")):
				m_InputsToProcess.append([STATES.NAVIGATION, PhysicsG.NULL_VECTOR])
	else:
		return false
	return true
	
func ParseAttackInput_E(event):
	if (event.is_action_pressed("attack")):
		m_InputsToProcess.append([STATES.ATTACK, PhysicsG.RIGHT])
	elif (event.is_action_pressed("attack2")):
		m_InputsToProcess.append([STATES.ATTACK, PhysicsG.UP])
	elif (event.is_action_pressed("attack3")):
		m_InputsToProcess.append([STATES.ATTACK, PhysicsG.DOWN])
	else:
		return false
		
	return true
		
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
	if (m_FacingRight):
		$hip.scale.x *= -1.0


func _on_Timer_timeout():
	m_CanFire = true
	
###########################################
# Sound

###########################################
# Damage
onready var m_MaxHealth = 100
onready var m_Health = m_MaxHealth

onready var m_PendingHurt = false

func OnDamage(damage):
	m_Health -= damage
	m_PendingHurt = true
