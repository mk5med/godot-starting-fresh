class_name Alertness
enum ALERT_LEVEL { CALM, LOW, HIGH }
var alert: float = 0
var speed: float = 3
var baseAlert: float = 0
var alertLevel: ALERT_LEVEL = ALERT_LEVEL.CALM
const THRESHOLD_ALERT_LOW = 1


func _init(_baseAlert: float = 0):
	self.baseAlert = _baseAlert
	self.alert = self.baseAlert
	_setAlertLevel()


func update(canSeePlayer: bool, timeElapsed: float):
	alert += timeElapsed * speed * (1 if canSeePlayer else -1)

	# Correct the alert level to not exceed the minimum
	alert = max(baseAlert, alert)
	_setAlertLevel()


func setAlert(_alert: float):
	self.alert = max(baseAlert, _alert)
	_setAlertLevel()


func _setAlertLevel():
	self.alertLevel = _getAlertLevel(alert)


func _getAlertLevel(_alert: float):
	if _alert == 0:
		return ALERT_LEVEL.CALM
	elif _alert <= THRESHOLD_ALERT_LOW:
		return ALERT_LEVEL.LOW
	else:
		return ALERT_LEVEL.HIGH
