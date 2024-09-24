extends TextureRect

var offset = Vector3(0, 0, 0)
var speed = Vector3(10, 0, 0) # Adjust the speed of the noise movement

func _process(delta):
	offset += speed * delta
	offset.y=sin(offset.x/4)
	modulate_texture_offset(offset)

func modulate_texture_offset(new_offset: Vector3):
	# Assuming the noise texture is a regular image, adjust the rect_position to move it
	self.texture.noise.offset=offset
