class_name ActionEventLog


# Helper method to store action changes
class ActionEvent:
	func _init(time: float, action: StringName, state: bool):
		self.time = time
		self.action = action
		self.state = state


func _init(actions: Array[StringName]):
	self.actions = actions
	self.currentState = {}
	self.events = []

	# Initialise the dictionary so all actions are false
	for action in actions:
		self.currentState[action] = false


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
	if self.currentState[action] != state:
		self.currentState[action] = state
		self.events.append(ActionEvent.new(currentTime, action, state))
	pass
