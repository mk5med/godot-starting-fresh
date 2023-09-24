## Mock for the built-in Input class
## This is used to replay input events on player clones
class_name InputMock

var actions = []
var state = {}


func _init(_actions):
	self.actions = _actions
	for action in actions:
		state[action] = false


func action_press(action: StringName):
	state[action] = true


func action_release(action: StringName):
	state[action] = false


func is_action_just_pressed(action: StringName):
	return state[action]


func get_axis(negative_action: StringName, positive_action: StringName):
	return int(state[positive_action]) - int(state[negative_action])
