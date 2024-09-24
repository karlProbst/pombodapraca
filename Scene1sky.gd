extends TextureRect


@export var followNode:Node 
func _process(delta):
	self.position.x=followNode.position.x-(1700/2)

	


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
