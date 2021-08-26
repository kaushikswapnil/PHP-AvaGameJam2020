extends KinematicBody2D

const PhysicsG = preload("res://physics_globals.gd")

var m_Velocity = Vector2(0, 0)

enum STATE_FLAGS { IDLE, NAVIGATION, JUMP, ATTACK, BLOCK, HURT, FALLING, DEAD }
var m_State = STATE_FLAGS.IDLE
var m_DesiredState = STATE_FLAGS.IDLE
var m_TimeSinceLastStateChange = 0.0

func init():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var desired_state = ParseInput()

func _physics_process(delta):
	pass

func ParseInput():
	var desired_state = m_State
	match m_State:
		STATE_FLAGS.IDLE:
			if (Input.is_action_pressed("jump")):
				desired_state = STATE_FLAGS.JUMP
			elif (Input.is_action_just_pressed("right") || Input.is_action_just_pressed("left")):
				desired_state = STATE_FLAGS.NAVIGATION
			elif (Input.is_action_just_pressed("attack")):
				desired_state = STATE_FLAGS.ATTACK
