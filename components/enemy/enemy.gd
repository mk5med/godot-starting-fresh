## Enemy class
class_name Enemy

extends StaticBody2D
var elapsed_time = 0
var vision_range = 5
@export var travel_points: Array[Vector2] = []

var index = 0


func _init():
	pass


func _ready():
	pass


func _physics_process(delta):
	# Find the direction from the target point to the current position in world space
	var direction = travel_points[index] - position

	look_at(direction)
	move_and_collide(direction * delta)

	# Increment the position to reach when the node is close enough
	if (position - travel_points[index]).length() <= 5:
		index += 1

	# Loop back when the index exceeds the array size
	if len(travel_points) <= index:
		index = 0
		return
	pass
