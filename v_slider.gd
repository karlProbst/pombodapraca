extends VSlider

@export var node:Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	change_shader_param(value)
	
func change_shader_param(value):
	var material = node.material  # Get the material of the sprite
	if material is ShaderMaterial:
		material.set_shader_parameter("colors",value)
	
