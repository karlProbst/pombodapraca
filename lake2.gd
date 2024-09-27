extends TextureRect
var a =0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	a+=delta
	$texture.texture.noise.offset.x+=delta+sin(a)/35
