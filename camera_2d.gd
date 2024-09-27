extends Camera2D
var initialFov = 0.55
var a=0
@export var MaximumRangeY:=Vector2(300,1600)
@onready var char = get_parent().get_node("CharacterBody2D")
var key_zoom = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var charSpd=char.velocity.x
	if initialFov>0:
		a+=delta/1000
		initialFov-=a/2
	var targetX=char.position.x+(charSpd/2)
	var max_speed=300
	var zoom_speed = clamp(abs(char.velocity.y+char.velocity.x) / max_speed, 0.7, 1.1)
	zoom_speed=clamp((2-zoom_speed)-initialFov,0.8,1.2)
	
	if Input.is_action_pressed("ui_up"):  # Assuming 'ui_accept' is mapped to space
		key_zoom+=delta
	if Input.is_action_pressed("ui_down"):  # Assuming 'ui_accept' is mapped to space
		key_zoom-=delta
	zoom = Vector2(lerp(zoom.x,zoom_speed+key_zoom,delta), lerp(zoom.y,zoom_speed+key_zoom,delta))  
	
	
	
	self.position.x=lerpf(position.x,targetX,delta*5)
	
	var targetY=char.position.y+(char.velocity.y/4)
	targetY=clampf(targetY,MaximumRangeY.x,MaximumRangeY.y)
	self.position.y=lerpf(position.y,targetY,delta*5)
	
