extends Area2D

@onready var detectionArea: Area2D = $DetectionArea
@onready var shape: CircleShape2D = $DetectionArea/Shape.shape as CircleShape2D
@export var growSpeed: float = 200

enum STATE { NONE, GROWING, DISSAPATING }
var elapsed_time: float = 0
var state: STATE = STATE.NONE
var maxRadius = 200
var minRadius = 0
const SUSPICION_LAYER = 2


func _input(event):
	if event.is_pressed() and event.as_text() == "G":
		doDistract()


func doDistract():
	state = STATE.GROWING
	shape.radius = minRadius
	# Enable the
	detectionArea.set_collision_layer_value(SUSPICION_LAYER, true)
	pass


func _draw():
	if state == STATE.GROWING:
		var color = Color.from_string("#ffffff80", Color.BLACK)
		color.a = 1 - shape.radius / maxRadius
		draw_circle(
			# Circle center relative to the position
			Vector2.ZERO,
			# Circle radius
			shape.radius,
			color
		)


func _process(delta):
	queue_redraw()


func _physics_process(delta):
	elapsed_time += delta
	if state == STATE.GROWING:
		shape.radius = move_toward(shape.radius, maxRadius, delta * growSpeed)

		if shape.radius == maxRadius:
			state = STATE.NONE
			shape.radius = minRadius
			detectionArea.set_collision_layer_value(SUSPICION_LAYER, false)

	pass


func _stateMachine():
	pass


func _on_detection_area_body_entered(body: Node2D):
	pass  # Replace with function body.
