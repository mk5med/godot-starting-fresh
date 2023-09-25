# This script is active as a tool so paths can be rendered
@tool

## Manages enemies in the level
class_name EnemyManager

extends Node


class EnemyMetadata:
	var enemy: Enemy
	var line2D: Line2D

	func _init(_enemy: Enemy, _line2D: Line2D):
		self.enemy = _enemy
		self.line2D = _line2D


var enemyMetadataList: Array[EnemyMetadata] = []


func _ready():
	# Get all enemies in the scene
	var enemies = get_parent().find_children("enemy")

	for enemy in enemies:
		addEnemy(enemy)
	pass


func addEnemy(enemy: Enemy):
	var line2d = Line2D.new()
	line2d.width = 2
	enemyMetadataList.append(EnemyMetadata.new(enemy, line2d))
	add_child(line2d)


func drawOverlay():
	for enemyData in enemyMetadataList:
		enemyData.line2D.clear_points()
		for point in enemyData.enemy.travel_points:
			enemyData.line2D.add_point(point)
			pass
	pass


func _process(delta):
	# drawOverlay()
	pass
