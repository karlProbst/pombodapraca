extends Node2D

@export var player: Node2D  # Reference to the player node
@export var selfSize: int = 2460  # Width of each lake instance
@export var next_lake: Node2D  # Reference to the second lake instance
@export var previous_lake: Node2D  # Reference to the third (previous) lake instance
var current_lake: Node2D = self  # The lake instance the player is currently on

const SHIFT_BUFFER = 300  # Preemptive buffer before reaching the edge

func _ready():
	# Set the initial lake positions

	previous_lake.position = current_lake.position - Vector2(selfSize, 0)  # Position previous lake to the left
	next_lake.position = current_lake.position + Vector2(selfSize, 0)  # Position next lake to the right

func _process(delta: float) -> void:
	# Check if player is near the right edge of the current lake and shift forward
	if player.position.x > current_lake.position.x + selfSize - SHIFT_BUFFER:
		_shift_lakes_forward()

	# Check if player is near the left edge of the current lake and shift backward
	elif player.position.x < current_lake.position.x + SHIFT_BUFFER:
		_shift_lakes_backward()

func _shift_lakes_forward() -> void:
	# Move the previous lake (which is behind) to the front, making it the new next lake
	previous_lake.position = next_lake.position + Vector2(selfSize, 0)

	# Rotate the lakes: previous becomes next, current becomes previous, and next becomes current
	var temp = previous_lake
	previous_lake = current_lake
	current_lake = next_lake
	next_lake = temp

func _shift_lakes_backward() -> void:
	# Move the next lake (which is ahead) to the back, making it the new previous lake
	next_lake.position = previous_lake.position - Vector2(selfSize, 0)

	# Rotate the lakes: next becomes previous, current becomes next, and previous becomes current
	var temp = next_lake
	next_lake = current_lake
	current_lake = previous_lake
	previous_lake = temp
