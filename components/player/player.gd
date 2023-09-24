extends CharacterBody2D
# CONFIG
var speed = 300
var jumpSpeed = -300
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var timeSinceStart = 0
var actionEventLog = ActionEventLog.new(["jump", "ui_left", "ui_right"])
var replayActionEventLog: ReplayActionEventLog = null

enum MODE { PLAY, REPLAY }

var mode = MODE.PLAY


func _ready():
	pass


func _input(_event: InputEvent):
	# Exit if this is not a key event
	if not (_event is InputEventKey):
		return

	# if is_on_floor() and Input.is_action_just_pressed("jump"):
	# 	actionEventLog.checkForStateUpdate(
	# 		"ui_left", Input.is_action_pressed("ui_left"), timeSinceStart
	# 	)

	# Don't log inputs while replaying
	if mode == MODE.REPLAY:
		return

	# Log whenever a non-jump key is pressed
	# For space efficiency storing jump events will be limited to valid events
	for action in ["ui_left", "ui_right", "start_fresh", "jump"]:
		actionEventLog.checkForStateUpdate(action, Input.is_action_pressed(action), timeSinceStart)

	# The reset button was pressed
	if Input.is_action_just_pressed("start_fresh"):
		var events = actionEventLog.events
		replayActionEventLog = ReplayActionEventLog.new(events)
		mode = MODE.REPLAY
		print("Replaying")
		pass


func _physics_process(delta):
	if mode == MODE.REPLAY:
		var done = replayActionEventLog.update(delta)
		if (done):
			print("Done")
			mode = MODE.PLAY

	# Increment the time so that event records can be replayed
	timeSinceStart += delta

	# Apply gravity
	self.velocity.y += gravity * delta

	# The jump button is pressed, and the player is on the ground
	if Input.is_action_just_pressed("jump") and is_on_floor():
		self.velocity.y = jumpSpeed

	var walk_velocity = Input.get_axis("ui_left", "ui_right")
	self.velocity.x = walk_velocity * speed
	move_and_slide()
	pass
