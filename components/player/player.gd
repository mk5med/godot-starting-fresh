extends CharacterBody2D
# CONFIG
var speed = 300
var jumpSpeed = -300
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	pass

func _input(event: InputEvent):
	pass

func _process(delta):
	
	pass

func _physics_process(delta):
	var walk_velocity = Input.get_axis("ui_left", "ui_right")
	self.velocity.y += gravity * delta

	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		self.velocity.y = jumpSpeed

	self.velocity.x = walk_velocity * speed
	move_and_slide()
	pass
