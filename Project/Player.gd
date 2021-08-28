extends KinematicBody2D

class_name Player

signal s_PlayAudio(audio_res)
signal s_PlayAnimation(animation_track)

const PhysicsG = preload("res://physics_globals.gd")

var m_Velocity = Vector2(0, 0)

var m_TimeSinceLastStateChange = 0.0

var m_FacingRight = true
var m_IsOnGround = false

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
		
	if (m_State == STATES.NAVIGATION):
		if (m_DesiredIntent == ENavigationalIntent.MoveLeft):
			desired_velocity.x = -PhysicsG.MAX_SPEED
		elif (m_DesiredIntent == ENavigationalIntent.MoveRight):
			desired_velocity.x = PhysicsG.MAX_SPEED
		else:
			desired_velocity.x = 0

	m_Velocity = move_and_slide(desired_velocity, PhysicsG.UP, true)
	m_IsOnGround = m_Velocity.y == 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ParseInput(delta)
	Statemachine_Process(delta)
	UpdateRender(delta)
	
###########################################
# statemachine

enum STATES { IDLE, NAVIGATION, JUMP, ATTACK, BLOCK, HURT, FALLING, DEAD }
var m_State = STATES.IDLE
var m_DesiredState = STATES.IDLE
var m_PreviousState = m_State

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
	
onready var m_NavigationIntent = ENavigationalIntent.Idle
func SM_Navigation(delta):
	print("Player : Navigation")
	if (m_DesiredState == m_State && m_DesiredIntent == ENavigationalIntent.Idle && m_Velocity.length() < 0.01):
		m_Velocity = Vector2(0.0, 0.0)
		m_DesiredState = STATES.IDLE
	if (!m_IsOnGround):
		m_DesiredState = STATES.IDLE
	SM_TransitionIfAny(m_DesiredState)
	
func SM_Navigation_OnEnter():
	emit_signal("s_PlayAnimation", "player_walk")
	
const JUMP_TIME = 1.2	
func SM_Jump(delta):
	print("Player : Jump")
	m_DesiredState = STATES.FALLING
	SM_TransitionIfAny(m_DesiredState)
	
func SM_Jump_OnEnter():
	m_Velocity.y = -300.0
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
	
onready var m_Weapon = $hip/abdomen/chest/arm_right/forearm_right/hand_right/weapon_slot/Weapon
var m_AttackCompleted = false
func SM_Attack(delta):
	print("Player : Attack")
	if(m_AttackCompleted):
		m_DesiredState = STATES.IDLE	
	SM_TransitionIfAny(m_DesiredState)
		
func SM_Attack_OnEnter():
	m_AttackCompleted = false
	if (m_DesiredIntent == EAttacks.A1):
		emit_signal("s_PlayAnimation", "player_attack_1")
	elif (m_DesiredIntent == EAttacks.A2):
		emit_signal("s_PlayAnimation", "player_attack_2")
	elif (m_DesiredIntent == EAttacks.A3):
		emit_signal("s_PlayAnimation", "player_attack_3")
	$PlayerAnimator.connect("animation_finished", self, "SM_OnAttackAnimation_Ended")
	m_Weapon.connect("OnDamageInflicted", self, "SM_OnAttack_TargetHit")
	
func SM_OnAttack_TargetHit(damage, body):
	m_Weapon.disconnect("OnDamageInflicted", self, "SM_OnAttack_TargetHit")
	
func SM_OnAttackAnimation_Ended(anim_name):
	m_AttackCompleted = true
	var facing = Vector2(1.0, 0.0)
	if !m_FacingRight:
		facing *= -1.0
	var new_platform_position = global_position
	var rotation_degree = rotation_degrees
	if anim_name == "player_attack_1":
		new_platform_position += (facing * 35.5) + Vector2(0.0, -3.5)
	elif anim_name == "player_attack_2":
		new_platform_position += (facing * 5.5) + Vector2(0.0, -24.0)
		rotation_degree += 30.0
	elif anim_name == "player_attack_3":
		new_platform_position += (facing * 3.5) + Vector2(0.0, 30.5)
		rotation_degree -= 30.0
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
	
	if (m_OwnedDevice == KeyBoard):
		if !(event is InputEventKey):
			return
	elif (m_OwnedDevice != event.device):
		return
		
	if (ParseAttackInput_E(event)):
		m_TimeSinceLastInput = 0 
	elif (ParseNavigationalInput_E(event)):
		m_TimeSinceLastInput = 0 
		m_TimeSinceLastNavigationalInput = 0
	return 
	
onready var m_DesiredIntent = 0
onready var m_DesiredIntentStrength = 0.0

func ParseInput(delta):
	m_TimeSinceLastInput += delta
	m_TimeSinceLastNavigationalInput += delta
	m_InputsProcessedThisFrame = false
	
	if (m_InputsToProcess.size() > 0):
			var x = m_InputsToProcess.back()
			m_DesiredState = x[0]
			m_DesiredIntent = x[1]
			m_DesiredIntentStrength = x[2]
			m_InputsToProcess.clear()
			m_InputsProcessedThisFrame = true
	else:
		m_DesiredState = m_State

enum ENavigationalIntent { Idle, MoveRight, MoveLeft }

func ParseNavigationalInput_E(event):
	if (m_IsOnGround):
		if (event.is_action_pressed("jump")):
			m_InputsToProcess.append([STATES.JUMP, 0, 1.0])
		elif (event.is_action_pressed("right")):
			if (event is InputEventJoypadMotion):
				m_InputsToProcess.append([STATES.NAVIGATION, ENavigationalIntent.MoveRight, event.axis_value])
			else:
				m_InputsToProcess.append([STATES.NAVIGATION, ENavigationalIntent.MoveRight, 1.0])
		elif (event.is_action_pressed("left")):
			if (event is InputEventJoypadMotion):
				m_InputsToProcess.append([STATES.NAVIGATION, ENavigationalIntent.MoveLeft, event.axis_value])
			else:
				m_InputsToProcess.append([STATES.NAVIGATION, ENavigationalIntent.MoveLeft, 1.0])
		elif (m_State == STATES.NAVIGATION):
			if (event.is_action_released("right") || event.is_action_released("left")):
				m_InputsToProcess.append([STATES.NAVIGATION, ENavigationalIntent.Idle, 0.0])
	else:
		return false
	return true
	
enum EAttacks { A1, A2, A3 }
	
func ParseAttackInput_E(event):
	if (event.is_action_pressed("attack")):
		if (event.is_action_pressed("up")):
			m_InputsToProcess.append([STATES.ATTACK, EAttacks.A2, 1.0])
		elif (event.is_action_pressed("down")):
			m_InputsToProcess.append([STATES.ATTACK, EAttacks.A3, 1.0])
		else:
			m_InputsToProcess.append([STATES.ATTACK, EAttacks.A1, 1.0])
	else:
		return false
		
	return true
	
###########################################
# Render

func UpdateRender(delta):
	if (m_FacingRight):
		if (m_Velocity.x < 0.0):
			m_FacingRight = false
			$hip.scale.x *= -1.0
	elif (m_Velocity.x > 0.0):
		m_FacingRight = true
		$hip.scale.x *= -1.0

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
