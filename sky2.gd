extends Node2D

@export var offset = Vector3(0, 0, 0)
@export var speed = Vector3(10, 0, 0) # Adjust the speed of the noise movement
@export var speedofDelta:float = 3.0
func _process(delta):
	offset += speed * delta/speedofDelta
	offset.y=sin(offset.x/4)
	modulate_texture_offset(offset)
func modulate_texture_offset(new_offset: Vector3):
	# Assuming the noise texture is a regular image, adjust the rect_position to move it
	$Sky.texture.noise.offset=offset
	$Sky.texture.color_ramp.set_offset(0, sin(offset.x/18)/2)
