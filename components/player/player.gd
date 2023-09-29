class_name Player
extends CharacterBody2D

var PlayerScene = load("res://components/player/player.tscn")
enum MODE { PLAY, REPLAY, IDLE }
const actions = ["ui_left", "ui_right", "ui_up", "ui_down"]

# CONFIG
var speed = 300
var timeSinceStart = 0

var actionEventLog: ActionEventLog = null
var replayActionEventLog: ReplayActionEventLog = null
var initialTransform: Transform2D
var inputSource = Input

var mode = MODE.PLAY
@onready var camera = $Camera2D


func _ready():
	self.actionEventLog = ActionEventLog.new(actions)
	self.initialTransform = Transform2D(self.transform)

	# Disable the camera if this is a clone
	if self.inputSource != Input:
		camera.enabled = false
		camera.queue_free()


func _input(_event: InputEvent):
	# Exit if this is not a key event
	if not (_event is InputEventKey):
		return

	# Don't log inputs while replaying
	if mode != MODE.PLAY:
		return

	# Log whenever a non-jump key is pressed
	# For space efficiency storing jump events will be limited to valid events
	for action in actions:
		actionEventLog.checkForStateUpdate(action, Input.is_action_pressed(action), timeSinceStart)

	# The reset button was pressed
	if Input.is_action_just_pressed("start_fresh"):
		startFresh()
		pass


func startFresh():
	var clone = PlayerScene.instantiate()
	clone.transform = initialTransform
	clone.inputSource = InputMock.new(actions)

	clone.replayActionEventLog = ReplayActionEventLog.new(
		actionEventLog.events.duplicate(), clone.inputSource
	)

	self.get_parent().add_child(clone)
	clone.name = "Player clone"
	clone.modulate.a = 0.5
	clone.mode = MODE.REPLAY

	# Reset the original array
	actionEventLog.reset()
	transform = initialTransform
	timeSinceStart = 0


func replayMode(delta: float):
	var done = replayActionEventLog.update(delta)
	if done:
		# Reset the event log
		actionEventLog.reset()

		self.mode = MODE.IDLE
		velocity = Vector2.ZERO
		# Disable the replay action object
		# replayActionEventLog = null

		# self.queue_free()
		return


func move(delta: float):
	# Increment the time so that event records can be replayed
	timeSinceStart += delta

	# The jump button is pressed, and the player is on the ground
	var yVelocity = inputSource.get_axis("ui_up", "ui_down")
	var xVelocity = inputSource.get_axis("ui_left", "ui_right")
	self.velocity.x = xVelocity * speed
	self.velocity.y = yVelocity * speed

	pass


func _physics_process(delta):
	if mode == MODE.REPLAY:
		replayMode(delta)
		if replayActionEventLog == null:
			# Reset the time
			timeSinceStart = 0

			# Skip processing
			return
	# # Apply gravity
	# self.velocity.y += gravity * delta
	if mode != MODE.IDLE:
		move(delta)
	move_and_slide()
