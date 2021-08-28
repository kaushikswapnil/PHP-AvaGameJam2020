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
var m_PlatformCollisionLayer
var m_PlatformCollisionMask

onready var m_ID = -1

const PLAYER_COLLISION_LAYER_OFFSET = 10

var m_ModulateColor = Color(0, 0, 0)

func init(device, modulate_color, id):
	m_OwnedDevice = device
	m_ModulateColor = modulate_color
	$hip.set_modulate(modulate_color)
	m_ID = id
	collision_layer = 1 << (m_ID + PLAYER_COLLISION_LAYER_OFFSET)
	collision_mask = 1 << 0
	for x in range(PLAYER_COLLISION_LAYER_OFFSET, PLAYER_COLLISION_LAYER_OFFSET + 5): #only five enemies now
		collision_mask += 1 << x
		
	var weapon_collision_mask = collision_mask - collision_layer
	m_PlatformCollisionLayer = 1 << (1 + m_ID)
	collision_mask += m_PlatformCollisionLayer
	m_PlatformCollisionMask = collision_layer
	
	m_Weapon.init(self, weapon_collision_mask)

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
	match m_State:
		STATES.HURT:
			SM_Hurt_OnExit()
	
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
		STATES.HURT:
			SM_Hurt_OnEnter()
	
	print("Transitioning to state ", m_State)
	
func SM_HasPendingTransition():
	return m_DesiredState != m_State
	
func SM_TransitionIfAny(to_state):
	if (SM_HasPendingTransition()):
		SM_Transition(m_DesiredState)
	
func SM_Idle(delta):
	if (!m_IsOnGround):
		m_DesiredState = STATES.FALLING
	SM_TransitionIfAny(m_DesiredState)

func SM_Idle_OnEnter():
	emit_signal("s_PlayAnimation", "player_idle")
	
onready var m_NavigationIntent = ENavigationalIntent.Idle
func SM_Navigation(delta):
	if (m_DesiredState == m_State && m_DesiredIntent == ENavigationalIntent.Idle && m_Velocity.length() < 0.01):
		m_Velocity = Vector2(0.0, 0.0)
		m_DesiredState = STATES.IDLE
	if (!m_IsOnGround):
		m_DesiredState = STATES.IDLE
	SM_TransitionIfAny(m_DesiredState)
	
func SM_Navigation_OnEnter():
	emit_signal("s_PlayAnimation", "player_walk")

func SM_Jump(delta):
	m_DesiredState = STATES.FALLING
	SM_TransitionIfAny(m_DesiredState)
	
func SM_Jump_OnEnter():
	m_Velocity.y = -300.0
	emit_signal("s_PlayAnimation", "player_jump")
	
func SM_Block(delta):
	print("Player : Block")
	SM_TransitionIfAny(m_DesiredState)
	
onready var m_HurtFrameCounter = 0
const HurtFramePersistence = 180

func SM_Hurt(delta):
	print("Player : Hurt")
	m_HurtFrameCounter += 1
	if (m_HurtFrameCounter >= HurtFramePersistence):
		m_DesiredState = STATES.IDLE
	else:
		var modulator = int(ceil(m_HurtFrameCounter / 8))
		var modulator_odd_even = modulator % 2
		if (modulator_odd_even == 1):
			var new_col = Color(1.0 - m_ModulateColor.r, 1.0 - m_ModulateColor.g, 1.0 - m_ModulateColor.b)
			$hip.set_modulate(new_col)
		else:
			$hip.set_modulate(m_ModulateColor)	
		
	SM_TransitionIfAny(m_DesiredState)
	
func SM_Hurt_OnEnter():
	m_HurtFrameCounter = 0
	m_PendingHurt = false
	
func SM_Hurt_OnExit():
	$hip.set_modulate(m_ModulateColor)	
	
func SM_FALLING(delta):
	if (!SM_HasPendingTransition() && m_IsOnGround):
		m_DesiredState = STATES.IDLE
	SM_TransitionIfAny(m_DesiredState)
	
func SM_Dead(delta):
	print("Player : Dead")
	SM_TransitionIfAny(m_DesiredState)
	
onready var m_Weapon = $hip/abdomen/chest/arm_right/forearm_right/hand_right/weapon_slot/Weapon
var m_AttackCompleted = false
func SM_Attack(delta):
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
	new_platform.set_modulate(m_ModulateColor)
	new_platform.collision_layer = m_PlatformCollisionLayer
	new_platform.collision_mask = m_PlatformCollisionMask
	$PlayerAnimator.disconnect("animation_finished", self, "SM_OnAttackAnimation_Ended")
	
###########################################
# input
#
onready var m_OwnedDevice = InvalidDevice
const KeyBoard = -1
const InvalidDevice = -2
onready var m_TimeSinceLastInput = 0

func _input(event):
	if (event is InputEventMouseButton || event is InputEventMouseMotion):
		return
	
	if (m_OwnedDevice == KeyBoard):
		if !(event is InputEventKey):
			return
	elif (m_OwnedDevice != event.device):
		return
	elif (event is InputEventKey): #no need to get key events in joypad players
		return
		
	TestInputActionForFrame(event, EInputActionMapping.Left)
	TestInputActionForFrame(event, EInputActionMapping.Right)
	TestInputActionForFrame(event, EInputActionMapping.Up)
	TestInputActionForFrame(event, EInputActionMapping.Down)
	TestInputActionForFrame(event, EInputActionMapping.Jump)
	TestInputActionForFrame(event, EInputActionMapping.Attack)
	
onready var m_DesiredIntent = 0
onready var m_DesiredIntentStrength = 0.0

enum EInputActionMapping { Left, Right, Up, Down, Jump, Attack, Count }
var m_FrameInputActionMapping = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
const m_EInputActionToNameMap = ["left", "right", "up", "down", "jump", "attack"]
const m_EInputActionToJoyButton = [JOY_DPAD_LEFT, JOY_DPAD_RIGHT, JOY_DPAD_UP, JOY_DPAD_DOWN, JOY_DS_B, JOY_DS_Y ]
const m_EInputActionToKey = [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN, KEY_SPACE, KEY_A ]
const m_EInputActionToAxis = [JOY_ANALOG_LX, JOY_ANALOG_LX, JOY_ANALOG_LY , JOY_ANALOG_LY , -1, -1 ]

func Input_IsKeyPressed(action):
	return m_FrameInputActionMapping[action] != 0.0

func Input_IsKeyReleased(action):
	return m_FrameInputActionMapping[action] == 0.0

func TestInputActionForFrame(event, action):
	var action_pressed = false
	var action_strength = 0.0
	var action_released = false
	if (event is InputEventKey):
		if event.scancode == m_EInputActionToKey[action]:
			if (event.pressed):
				action_strength = 1.0
				action_pressed = true
			else:
				action_released = true
	elif (event is InputEventJoypadButton):
		if (event.button_index == m_EInputActionToJoyButton[action]):
			if (event.pressed):
				action_pressed = true
				action_strength = 1.0
			else:
				action_released = true
	elif (event is InputEventJoypadMotion):
		if (event.axis == m_EInputActionToAxis[action]):
			action_strength = event.axis_value
			action_released = true
		
	if (action_pressed || action_released):
		m_FrameInputActionMapping[action] = action_strength
		m_TimeSinceLastInput = 0.0
		return true

func ParseInput(delta):
	m_TimeSinceLastInput += delta
	
	if (!ParseAttackInput()):
		ParseNavigationalInput()
		
func ParseNavigationalInput():
	if (m_IsOnGround):
		if (Input_IsKeyPressed(EInputActionMapping.Jump)):
			m_DesiredState = STATES.JUMP
			m_DesiredIntent = 0
			m_DesiredIntentStrength = 1.0
		elif (m_FrameInputActionMapping[EInputActionMapping.Right] > 0.0):
			m_DesiredState = STATES.NAVIGATION
			m_DesiredIntent = ENavigationalIntent.MoveRight
			m_DesiredIntentStrength = 1.0
		elif (m_FrameInputActionMapping[EInputActionMapping.Left] < 0.0 || Input_IsKeyPressed(EInputActionMapping.Left)):
			m_DesiredState = STATES.NAVIGATION
			m_DesiredIntent = ENavigationalIntent.MoveLeft
			m_DesiredIntentStrength = 1.0
		elif (m_State == STATES.NAVIGATION):
			m_DesiredState = STATES.NAVIGATION
			m_DesiredIntent = ENavigationalIntent.Idle
			m_DesiredIntentStrength = 0.0
		else:
			return false
		return true
		
func ParseAttackInput():
	if (Input_IsKeyPressed(EInputActionMapping.Attack)):
		m_DesiredState = STATES.ATTACK
		m_DesiredIntentStrength = 1.0
		if (m_FrameInputActionMapping[EInputActionMapping.Up] > 0.0):
			m_DesiredIntent = EAttacks.A2
		elif (m_FrameInputActionMapping[EInputActionMapping.Down] < 0.0 || Input_IsKeyPressed(EInputActionMapping.Down)):
			m_DesiredIntent = EAttacks.A3
		else:
			m_DesiredIntent = EAttacks.A1
		
		return true
	
	return false

enum ENavigationalIntent { Idle, MoveRight, MoveLeft }
	
enum EAttacks { A1, A2, A3 }
	
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
