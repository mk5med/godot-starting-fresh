## Enemy class
class_name Enemy

extends StaticBody2D

enum ENEMY_STATE { IDLE, MOVING, HUNTING }

var elapsed_time = 0
var vision_range = 5
@export var travel_points: Array[Vector2] = []

var baseState = ENEMY_STATE.IDLE

var state: ENEMY_STATE = baseState
var alertness = Alertness.new()
var unknownObject: Node2D = null

var action_hunt: EnemyActionHunt
var action_move: EnemyActionMove

var startPos: Vector2
var movingBack = false
@onready var navigationAgent = $NavigationAgent2D


func _ready():
	navigationAgent.path_desired_distance = 4.0
	navigationAgent.target_desired_distance = 4.0
	action_hunt = EnemyActionHunt.new(self)
	action_move = EnemyActionMove.new(self, travel_points)


func setState(_state: ENEMY_STATE):
	# NOP
	if state == _state:
		return

	if _state == ENEMY_STATE.HUNTING:
		# Log the position when hunting started
		startPos = position

	## BEGIN CODE FOR MOVING BACK AFTER HUNTING
	# The enemy was moving back and has returned to the starting position
	if movingBack and startPos == position:
		movingBack = false

	# The state was previously hunting and it is being transitioned to a non-hunting state
	if state == ENEMY_STATE.HUNTING and startPos != position:
		# Move the enemy to the position before hunting started
		action_move.setNextLocation(startPos)
		movingBack = true

	if movingBack:
		# Modify the next state to be moving
		_state = ENEMY_STATE.MOVING
	## END CODE FOR MOVING BACK AFTER HUNTING

	# Update the state
	state = _state


func calculateState():
	# If the enemy is hunting and the suspicious object has not been lost (CHASING or SEARCHING)
	if state == ENEMY_STATE.HUNTING:
		# CHASING or SEARCHING blocks ALERT_LEVEL from decreasing
		if action_hunt.state != EnemyActionHunt.HUNT_STATE.LOST:
			return
		else:
			# Change the alert to LOW
			alertness.setAlert(alertness.THRESHOLD_ALERT_LOW)

	# state is HUNTING and LOST, MOVING, or IDLE
	var aLevel = alertness.alertLevel

	if aLevel == Alertness.ALERT_LEVEL.CALM:
		# Return to normal
		setState(baseState)
	elif aLevel == Alertness.ALERT_LEVEL.LOW:
		# Stop and wait for something to happen
		setState(ENEMY_STATE.IDLE)
	elif aLevel == Alertness.ALERT_LEVEL.HIGH:
		# Hunt the suspicious activity
		setState(ENEMY_STATE.HUNTING)


## STATE MANAGEMENT
func updateState(delta: float):
	# Only update the alert level if the enemy is not currently hunting
	if state != ENEMY_STATE.HUNTING:
		alertness.update(unknownObject != null, delta)

	calculateState()


func _physics_process(delta):
	updateState(delta)

	# If the enemy is hunting
	if state == ENEMY_STATE.HUNTING:
		action_hunt.setSuspicousObjectInView(unknownObject)
		action_hunt.update(delta)

	# The enemy is patrolling or moving back
	elif state == ENEMY_STATE.MOVING:
		action_move.update(delta)


func _onSomethingEntered(body: Node2D):
	unknownObject = body


func _onSomethingExited(_body: Node2D):
	unknownObject = null
