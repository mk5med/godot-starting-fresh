## Enemy class
class_name Enemy

extends StaticBody2D

enum ENEMY_STATE { IDLE, MOVING, HUNTING }

var elapsed_time = 0
var vision_range = 5
@export var travel_points: Array[Vector2] = []

var index = 0

var baseState = ENEMY_STATE.IDLE
var state: ENEMY_STATE = baseState
var alertness = Alertness.new()
var player: Node2D = null
var hunt: Hunt


func _init():
	hunt = Hunt.new(self)


func followPath(delta):
	if len(travel_points) == 0:
		return

	# Find the direction from the target point to the current position in world space
	var direction = (travel_points[index] - position).normalized()

	look_at(direction)
	move_and_collide(direction * delta)

	# Increment the position to reach when the node is close enough
	if (position - travel_points[index]).length() <= 5:
		index += 1

	# Loop back when the index exceeds the array size
	if len(travel_points) <= index:
		index = 0
		return


func _physics_process(delta):
	elapsed_time += delta

	# If the enemy is hunting
	if state == ENEMY_STATE.HUNTING:
		# Track the player while in range
		if player != null:
			hunt.setSearchPos(player.position)
			hunt.setState(Hunt.HUNT_STATE.CHASING)
		else:
			hunt.setState(Hunt.HUNT_STATE.SEARCHING)

		hunt.update(delta)

		# Don't process further
		if hunt.state != Hunt.HUNT_STATE.LOST:
			return

	# Update the alertness
	alertness.update(player != null, delta)
	var aLevel = alertness.alertLevel

	if aLevel == Alertness.ALERT_LEVEL.CALM:
		# Return to normal
		state = baseState
	elif aLevel == Alertness.ALERT_LEVEL.LOW:
		# Stop and wait for something to happen
		state = ENEMY_STATE.IDLE
	elif aLevel == Alertness.ALERT_LEVEL.HIGH:
		# Hunt the suspicious activity
		state = ENEMY_STATE.HUNTING

	if state == ENEMY_STATE.MOVING:
		followPath(delta)


func _onSomethingEntered(body: Node2D):
	player = body
	hunt.setSearchPos(player.position)


func _onSomethingExited(_body: Node2D):
	player = null
