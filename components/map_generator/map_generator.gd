@tool
extends TileMap

var _texture: CompressedTexture2D
@export var mapTexture: CompressedTexture2D:
	set(val):
		_texture = val
		# Update the map when it is updated
		createMap()
		pass
	get:
		return _texture


func _init():
	createMap()


func _ready():
	createMap()


func createMap():
	if _texture == null:
		return
	self.clear()
	var w = mapTexture.get_width()
	var h = mapTexture.get_height()

	var data = mapTexture.get_image()

	for x in range(w):
		for y in range(h):
			if data.get_pixel(x, y) == Color.BLACK:
				self.set_cell(0, Vector2(x, y), 0, Vector2(0, 0))
