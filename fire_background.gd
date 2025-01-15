extends Node2D


var offset = Vector3(0, 0, 0)
var speed = Vector3(10, 0, 0)

@export var followNode:Node 
func _process(delta):
	
	offset += speed * delta/3
	offset.y+=(delta*10)
	modulate_texture_offset(offset,delta)
func modulate_texture_offset(new_offset: Vector3,delta:float):

	$GradientFireMask/FireRed.texture.noise.offset=offset
	$BlobFireGradientMask/FireTextureRect.texture.noise.offset=offset
