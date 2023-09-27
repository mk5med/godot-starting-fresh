class_name EnemyActionMove
var travel_points = []
var index = 0
var enemy: Enemy

# This is a Vector2
# TODO: How to specify the type of a variable as Null or Vector2
var nextLocation
var speed = 100
var navigationAgent: NavigationAgent2D


func _init(_enemy, _travel_points):
	travel_points = _travel_points
	enemy = _enemy
	navigationAgent = enemy.get_node("NavigationAgent2D")

	# Initialise the next location to navigate if it exists
	if len(travel_points) > 0:
		setNextLocation(travel_points[index])


func update(delta: float):
	if navigationAgent.is_navigation_finished():
		return

	if nextLocation == null:
		return

	# Find the direction from the target point to the current position in world space
	var curGlobalPos = enemy.global_position
	var nextGlobalPos = navigationAgent.get_next_path_position()
	var direction = (nextGlobalPos - curGlobalPos).normalized()

	print("Going from %s to %s with direction %s" % [curGlobalPos, nextGlobalPos, direction])

	# Look at the direction to move
	enemy.look_at(nextGlobalPos)

	# Move
	enemy.move_and_collide(direction * delta * speed)

	# Increment the position to reach when the node is close enough
	if (enemy.position - nextLocation).length() <= 5:
		# Do not increment the index if the last travel location
		# was not in the normal travel path of the enemy
		# This prevents the enemy from skipping a travel point
		# after returning from hunting

		var _nextLocation
		# travel_points has no data. There is nothing to load
		if len(travel_points) == 0:
			_nextLocation = null
		# The last location was not a normal path to travel
		# Reload the current index
		elif travel_points[index] != nextLocation:
			_nextLocation = _nextLocation[index]
		# The last movement was in the travel_points path
		# Move the location forward
		else:
			# Increment the index to get the next location
			index += 1

			# Loop back when the index exceeds the array size
			if len(travel_points) <= index:
				index = 0
			_nextLocation = travel_points[index]
		setNextLocation(_nextLocation)


## Set the next location to navigate to
func setNextLocation(pos):
	nextLocation = pos
	if pos != null:
		navigationAgent.target_position = pos
