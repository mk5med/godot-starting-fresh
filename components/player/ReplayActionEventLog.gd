## This class replays action events
class_name ReplayActionEventLog

var events: Array[ActionEventLog.ActionEvent]
var elapsed_time = 0
var index = 0
var done = false

func _init(_events):
	self.events = _events as Array[ActionEventLog.ActionEvent]
	self.elapsed_time = 0


func update(delta: float):
	# Increment the current time
	self.elapsed_time += delta

	# While the index hasn't reached the end of the array
	# And there are events to replay
	while index < len(events) and events[index].time < self.elapsed_time:
		
		var event = events[index]
		print("Replaying ", event)

		# If this was a positive change
		if event.state:
			Input.action_press(event.action)
		else:
			Input.action_release(event.action)

		# Move to the next element
		index += 1
	
	done = index == len(events)
	return done