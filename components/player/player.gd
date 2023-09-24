extends CharacterBody2D
# CONFIG
var speed = 300
var jumpSpeed = -300
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var timeSinceStart = 0
var actionEventLog = ActionEventLog.new(["jump", "ui_left", "ui_right"])


func _ready():
	pass


func _input(event: InputEvent):
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		actionEventLog.checkForStateUpdate(
			"ui_left", Input.is_action_pressed("ui_left"), timeSinceStart
		)

	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		actionEventLog.checkForStateUpdate(
			"ui_left", Input.is_action_pressed("ui_left"), timeSinceStart
		)
		actionEventLog.checkForStateUpdate(
			"ui_right", Input.is_action_pressed("ui_right"), timeSinceStart
		)
		# An event was pressed
		pass
	# The reset button was pressed
	if Input.is_action_just_pressed("start_fresh"):
		pass
	pass


func _process(delta):
	pass


func _physics_process(delta):
	# Increment the time so that event records can be replayed
	timeSinceStart += delta

	var walk_velocity = Input.get_axis("ui_left", "ui_right")
	self.velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		self.velocity.y = jumpSpeed

	self.velocity.x = walk_velocity * speed
	move_and_slide()
	pass
