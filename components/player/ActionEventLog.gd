class_name ActionEventLog


# Helper method to store action changes
class ActionEvent:
	var time: float
	var action: String
	var state: bool

	func _init(_time: float, _action: StringName, _state: bool):
		self.time = _time
		self.action = _action
		self.state = _state

	func _to_string():
		# Pretty print the output
		return JSON.stringify({"time": self.time, "action": self.action, "state": self.state})


var actions = []
var currentState = {}
var events: Array[ActionEvent] = []


func _init(_actions):
	self.actions = _actions
	self.currentState = {}
	self.events = []

	# Initialise the dictionary so all actions are clean
	for action in actions:
		# Set states to false
		self.currentState[action] = false

		# Release all keys
		self.events.append(ActionEvent.new(0, action, false))


## checkForStateUpdate
## This will append time-based state changes to a list of events
func checkForStateUpdate(action: StringName, state: bool, currentTime: float):
	if action not in self.currentState:
		return null
	assert(
		action in self.currentState,
		(
			"Action "
			+ action
			+ " was not included in the constructor."
			+ "Available actions: "
			+ str(self.actions)
		)
	)

	# Only record state changes
	if self.currentState[action] != state:
		self.currentState[action] = state
		self.events.append(ActionEvent.new(currentTime, action, state))
	pass


func serialise():
	return events
