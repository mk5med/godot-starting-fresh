class_name Player
extends CharacterBody2D

var PlayerScene = load("res://components/player/player.tscn")

# CONFIG
var speed = 300
var jumpSpeed = -300
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var timeSinceStart = 0
var actionEventLog: ActionEventLog = null
var replayActionEventLog: ReplayActionEventLog = null
var initialTransform: Transform2D
var inputSource = Input
enum MODE { PLAY, REPLAY }

var mode = MODE.PLAY


func _ready():
	self.actionEventLog = ActionEventLog.new(["jump", "ui_left", "ui_right"])
	self.initialTransform = Transform2D(self.transform)
	pass


func _input(_event: InputEvent):
	# Exit if this is not a key event
	if not (_event is InputEventKey):
		return

	# Don't log inputs while replaying
	if mode == MODE.REPLAY:
		return

	# Log whenever a non-jump key is pressed
	# For space efficiency storing jump events will be limited to valid events
	for action in ["ui_left", "ui_right", "start_fresh", "jump"]:
		actionEventLog.checkForStateUpdate(action, Input.is_action_pressed(action), timeSinceStart)

	# The reset button was pressed
	if Input.is_action_just_pressed("start_fresh"):
		startFresh()
		pass


func startFresh():
	var clone = PlayerScene.instantiate()
	clone.transform = initialTransform
	clone.inputSource = InputMock.new(["jump", "ui_left", "ui_right"])

	clone.replayActionEventLog = ReplayActionEventLog.new(
		actionEventLog.events.duplicate(), clone.inputSource
	)

	self.get_parent().add_child(clone)
	clone.name = "Player clone"
	clone.modulate.a = 0.5
	clone.mode = MODE.REPLAY

	# Reset the original array
	actionEventLog.reset()


func replayMode(delta: float):
	var done = replayActionEventLog.update(delta)
	print("Done: ", done, replayActionEventLog.index, replayActionEventLog.events)
	if done:
		# Reset the event log
		actionEventLog.reset()

		# Disable the replay action object
		replayActionEventLog = null

		self.queue_free()
		return

func move(delta: float):
	# Increment the time so that event records can be replayed
	timeSinceStart += delta

	# Apply gravity
	self.velocity.y += gravity * delta

	# The jump button is pressed, and the player is on the ground
	if inputSource.is_action_just_pressed("jump") and is_on_floor():
		self.velocity.y = jumpSpeed

	var walk_velocity = inputSource.get_axis("ui_left", "ui_right")
	self.velocity.x = walk_velocity * speed
	move_and_slide()
	pass

func _physics_process(delta):
	if mode == MODE.REPLAY:
		replayMode(delta)
		if replayActionEventLog == null:
			# Reset the time
			timeSinceStart = 0

			# Skip processing
			return
	
	move(delta)