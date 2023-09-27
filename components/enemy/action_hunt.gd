class_name EnemyActionHunt
enum HUNT_STATE { LOST, SEARCHING, CHASING }
const SEARCH_TIME = 5

var suspiciousPos: Vector2
var enemy: Enemy
var state: HUNT_STATE = HUNT_STATE.SEARCHING
var searchTimeRemaining = SEARCH_TIME
var navigationAgent: NavigationAgent2D
var huntSpeed = 150


func _init(_enemy: Enemy):
	self.enemy = _enemy
	navigationAgent = enemy.get_node("NavigationAgent2D")


func update(delta: float):
	if state == HUNT_STATE.SEARCHING:
		# Decrement the search time if searching
		searchTimeRemaining = max(0, searchTimeRemaining - delta)

		# The search time has elapsed
		if searchTimeRemaining == 0:
			setState(HUNT_STATE.LOST)

	# Stop processing when the enemy gives up
	if state == HUNT_STATE.LOST:
		return

	# The hunt is SEARCHING or CHASING

	if state == HUNT_STATE.CHASING:
		self.enemy.look_at(suspiciousPos)

		var curGlobalPos = enemy.global_position
		var nextGlobalPos = navigationAgent.get_next_path_position()
		var direction = (nextGlobalPos - curGlobalPos).normalized()

		print(
			(
				"HUNTING: Going from %s to %s with direction %s"
				% [curGlobalPos, nextGlobalPos, direction]
			)
		)

		# Look at the direction to move
		enemy.look_at(nextGlobalPos)

		# Move
		enemy.move_and_collide(direction * delta * huntSpeed)

		if navigationAgent.is_navigation_finished():
			print("Done navigation to %s " % [suspiciousPos])
			setState(HUNT_STATE.SEARCHING)

	else:
		# The hunt is SEARCHING
		# Rotate 360 degrees
		self.enemy.rotation = PI / SEARCH_TIME * sin(4 * searchTimeRemaining)


var suspiciousObjectInView = false


func setSuspicousObjectInView(suspiciousObject):
	suspiciousObjectInView = suspiciousObject != null

	if suspiciousObjectInView:
		var _s = suspiciousObject as Node2D
		setSearchPos(suspiciousObject.global_position)
		setState(HUNT_STATE.CHASING)


func setSearchPos(pos: Vector2):
	self.suspiciousPos = pos
	navigationAgent.target_position = pos


func setState(_state: HUNT_STATE):
	# If the enemy has transitioned into a searching state
	if _state != state and state == HUNT_STATE.SEARCHING:
		searchTimeRemaining = SEARCH_TIME
	state = _state
