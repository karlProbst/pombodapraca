extends TextureRect

var offset = Vector3(0, 0, 0)
var speed = Vector3(10, 0, 0) 
var a = 0
@export var multiplierVector2:Vector2
@export var offsetVector2:Vector2
@export var node:Node




func _process(delta):
	position.x=offsetVector2.x-(node.position.x/100)*multiplierVector2.x
	a+=delta
	offset += speed * delta/4
	offset.y=sin(offset.x/4)
	modulate_texture_offset(offset,delta)
func modulate_texture_offset(new_offset: Vector3,delta):
	$TextureRect.texture.noise.offset=offset
	$TextureRect.texture.color_ramp.set_offset(1,(sin(a)/2)+1.5)
	$TextureRect.texture.color_ramp.set_offset(0, sin(offset.x/18)/2)
