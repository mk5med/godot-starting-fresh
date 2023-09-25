class_name Hunt
enum HUNT_STATE { LOST, SEARCHING, CHASING }
const SEARCH_TIME = 5

var suspiciousPos: Vector2
var enemy: Enemy
var state: HUNT_STATE = HUNT_STATE.SEARCHING
var searchTimeRemaining = SEARCH_TIME


func _init(_enemy: Enemy):
	print(_enemy)
	self.enemy = _enemy


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
	self.enemy.look_at(suspiciousPos)

	# Navigate towards the position
	var dir = (suspiciousPos - self.enemy.position).normalized()
	self.enemy.move_and_collide(dir * delta * 300)


func setSearchPos(pos: Vector2):
	self.suspiciousPos = pos


func setState(_state: HUNT_STATE):
	# If the enemy has transitioned into a searching state
	if _state != state and state == HUNT_STATE.SEARCHING:
		searchTimeRemaining = SEARCH_TIME
	state = _state
