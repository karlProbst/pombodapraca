extends Node2D
@export var multiplierVector2:Vector2
@export var offsetVector2:Vector2
@export var node:Node

func _process(delta: float) -> void:
	position.x=offsetVector2.x-(node.position.x/100)*multiplierVector2.x
	position.y=offsetVector2.y-(node.position.y/500)*multiplierVector2.y
