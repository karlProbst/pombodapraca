extends Node2D
var offset = Vector3(0, 0, 0)
var speed = Vector3(10, 0, 0)

@export var followNode:Node 
func _ready():
	print(followNode)
func _process(delta):
	
	self.position.x=followNode.position.x-(1700/2)
	offset += speed * delta/3
	offset.y=sin(offset.x/6)/2
	modulate_texture_offset(offset)
func modulate_texture_offset(new_offset: Vector3):

	$Sky.texture.noise.offset=offset
	$Sky.texture.color_ramp.set_offset(0, sin(offset.x/18)/2)


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
