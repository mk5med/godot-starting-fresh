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
var player: Player = null
var hunt: Hunt = Hunt.new(self)


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

	alertness.update(player != null, delta)

	match alertness.alertLevel:
		Alertness.ALERT_LEVEL.CALM:
			# Return to normal
			state = baseState
		Alertness.ALERT_LEVEL.LOW:
			# Stop and wait for something to happen
			state = ENEMY_STATE.IDLE
		Alertness.ALERT_LEVEL.HIGH:
			# Hunt the suspicious activity
			state = ENEMY_STATE.HUNTING

	if state == ENEMY_STATE.MOVING:
		followPath(delta)
	elif state == ENEMY_STATE.HUNTING:
		# Track the player while in range
		if player != null:
			hunt.setSearchPos(player.position)

		hunt.update(delta)
	pass


func _on_detection_area_body_entered(body):
	print("Entered ", body)
	player = body
	hunt.setSearchPos(player.position)
	pass


func _on_detection_area_body_exited(body):
	print("Exited ", body)
	player = null
	pass


class Hunt:
	enum HUNT_STATE { LOST, SEARCHING, CHASING }
	var suspiciousPos: Vector2
	var enemy: Enemy
	var state: HUNT_STATE = HUNT_STATE.SEARCHING

	func _init(_enemy: Enemy):
		print(_enemy)
		self.enemy = _enemy

	func update(delta: float):
		self.enemy.look_at(suspiciousPos)

	func setSearchPos(pos: Vector2):
		self.suspiciousPos = pos


class Alertness:
	enum ALERT_LEVEL { CALM, LOW, HIGH }
	var alert: float = 0
	var speed: float = 1
	var baseAlert: float = 0
	var alertLevel: ALERT_LEVEL = ALERT_LEVEL.CALM

	func _init(_baseAlert: float = 0):
		self.baseAlert = _baseAlert
		self.alert = self.baseAlert
		setAlertLevel()

	func update(canSeePlayer: bool, timeElapsed: float):
		alert += timeElapsed * speed * (1 if canSeePlayer else -1)

		# Correct the alert level to not exceed the minimum
		alert = max(baseAlert, alert)
		setAlertLevel()

	func setAlert(_alert: float):
		self.alert = max(baseAlert, _alert)
		setAlertLevel()

	func setAlertLevel():
		self.alertLevel = _getAlertLevel(alert)

	func _getAlertLevel(_alert: float):
		if _alert == 0:
			return ALERT_LEVEL.CALM
		elif _alert <= 2:
			return ALERT_LEVEL.LOW
		else:
			return ALERT_LEVEL.HIGH
