extends Node2D


var offset = Vector3(0, 0, 0)
var speed = Vector3(10, 0, 0)

@export var followNode:Node 
func _process(delta):
	
	offset += speed * delta/3
	offset.y+=sin(offset.x/40)+(delta*5)
	modulate_texture_offset(offset,delta)
func modulate_texture_offset(new_offset: Vector3,delta:float):

	$GradientMask/FireRed.texture.noise.offset=offset
	$GradientMask/FireRed.texture.color_ramp.set_offset(0, sin(offset.x/18)/2)
