extends CharacterBody2D

const FLAP_STRENGTH = -120.0  # Strength of the bird's flap (jump)
const GRAVITY = 600.0  # Gravity applied to the bird while gliding
const GLIDE_GRAVITY = 300.0  # Gravity when holding glide
const SPEED = 250.0  # Horizontal speed
const ACCELERATION = 400.0  # Horizontal acceleration
const FLAP_COOLDOWN = 0.25  # Reduced gravity during glide
const GLIDE_SPEED = 300.0    # Speed during glide
const GLIDE_HOLD_TIME = 0.5 # Time between flaps
const MAX_PITCH_ANGLE = 90.0  # Maximum up/down pitch angle (degrees)
const PITCH_SPEED = 60.0
var flight_speed = 0
var bounce_damping = 0.67
var buoyancy_force = -3500
var water_time=0
@onready var animatedSprite = $Pivot/Pombo
@onready var scaleDefault=scale
var flap_cooldown_timer = 0.0
var is_gliding = false
@onready var raycast=$RayCast2D
@onready var rayForward=$Pivot/RayFoward
@onready var rayBackward=$Pivot/RayBackward
var blackness = 10
var a = 0
const velPunchMax=200
var falling=false
var glide_angle = 0.0  # Glide angle in degrees
var space_hold_time = 0.0  # Time spacebar is held
var is_right = true
var glide_lock=false
var flap_lock=false
var glide_buffer_jump = 0.0
var in_water = false
func ChangeColor(blackness: float) -> void:
	if blackness>7:
		blackness=7
	blackness=10-blackness
	if blackness<0:
		blackness=0
	var black = Color.BLACK
	var white = Color.FLORAL_WHITE
	var normalized_blackness = clamp(blackness / 10.0, 0.0, 1.0)  # Normalize the value between 0 and 1
	animatedSprite.modulate = black.lerp(white, normalized_blackness)
	$GPUParticles2D.modulate = black.lerp(white, normalized_blackness+0.2)

	$Pivot/Pombo/ColorRect.modulate.a=2-normalized_blackness*2
	
	
	


	
func _physics_process(delta: float) -> void:
	
	if is_on_floor():
		$GPUParticles2D.emitting=false
	else:
		$GPUParticles2D.emitting=true

	#bater de cara
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		
		var collision = raycast.get_collider()
		var collisionPoint = raycast.get_collision_point()
		var collisionNormal = raycast.get_collision_normal()
		
		if collision.is_in_group("water"):
			in_water=true
			if blackness>0:
				blackness-=delta
	else:
		in_water=false
	if rayBackward.is_colliding():
		var collision = rayBackward.get_collider()
		var collisionPoint = rayBackward.get_collision_point()
		var collisionNormal = rayBackward.get_collision_normal()

		if collision and !collision.is_in_group("smoke")and !collision.is_in_group("water"):
			if collisionPoint and not falling:
				if (velocity.x>velPunchMax and !is_right) or (velocity.x<-velPunchMax and is_right):
					velocity = velocity.bounce(collisionNormal)*1.5
					$ExplodingFeather.emitting=true
	else:
		if rayForward.is_colliding():
			var collision = rayForward.get_collider()
			var collisionPoint = rayForward.get_collision_point()
			var collisionNormal = rayForward.get_collision_normal()
			
		
			if collision:
				
				if collision.is_in_group("smoke") :
					blackness += delta*40
				elif !collision.is_in_group("water"):
					if collisionPoint and abs(velocity.x)> velPunchMax:
					
						is_right=!is_right
						velocity = velocity.bounce(collisionNormal)/1.5
						is_gliding=false
						$ExplodingFeather.emitting=true
						falling=true	

					
	if(blackness>0):
		blackness-=delta
		ChangeColor(blackness)

	if Input.is_action_pressed("ui_accept"):  # Assuming 'ui_accept' is mapped to space
		space_hold_time += delta

	if Input.is_action_just_released("ui_accept") and flap_cooldown_timer <= 0.0 and !is_gliding and !flap_lock:
		if space_hold_time>0.5:
			if is_on_floor():
				space_hold_time=0.65
			else:
				space_hold_time=0.5
		flap(space_hold_time)
		
		
	if !Input.is_action_pressed("ui_accept"):
		glide_lock=false
		flap_lock=false
		space_hold_time = 0.0
		is_gliding=false

	if space_hold_time >= GLIDE_HOLD_TIME and !is_gliding and !falling and !glide_lock and !is_on_floor():
		enter_glide_mode()
	
	if is_right:
		$Pivot.scale.x =  1
	if !is_right:
		$Pivot.scale.x =  -1
		
	
	var direction = Input.get_axis("ui_left", "ui_right")
	if in_water:
		water_time+=delta*7
		velocity.y += GRAVITY * delta
		# Apply upward buoyancy force

		print(buoyancy_force)
		velocity.y += buoyancy_force * delta*((1+water_time))

		if velocity.y < 0:
			velocity.y *= bounce_damping
		velocity.x = lerpf(velocity.x, 0, delta * 3)

	elif is_gliding:
		glide(delta)
	else:
		water_time=0
		if direction < 0:
			is_right=false		
		elif direction > 0:
			is_right=true
		if !in_water:
			velocity.y += GRAVITY * delta
		if is_on_floor():
			animatedSprite.animation="still"
		else:
			animatedSprite.animation="flying"

				# Apply flapping cooldown
	if flap_cooldown_timer > 0.0:
		flap_cooldown_timer -= delta			
	
	# Handle flapping (jump)

	

	if is_on_floor():
		if is_gliding:
			is_gliding=false
		if falling:
			falling = false
		if abs(velocity.x)<3:
			velocity.x=0.0
		velocity.x += (direction*ACCELERATION) * delta
		velocity.x = lerpf(velocity.x,0.0,delta*5)
		
	else:
		if not falling and not is_gliding:
			velocity.x += (direction*ACCELERATION) * delta
			velocity.x = lerpf(velocity.x,0.0,delta/2)

	# Move the bird
	move_and_slide()

	# Rotate the bird based on vertical velocity for a gliding effect
	
func enter_glide_mode():
	velocity.y=-500
	
	
	if is_right:
		velocity.x+=100
	else:
		velocity.x-=100
	flight_speed=(abs(velocity.x)+abs(velocity.y))/2
	if flight_speed<1:
		flight_speed=1
	glide_buffer_jump=0.0
	glide_lock=true
	flap_lock=true
	is_gliding = true
	glide_angle = 45.0
	
func glide(delta):
	glide_buffer_jump += delta
	space_hold_time = 0.0

	# Determine the direction based on whether the player is facing right or left
	var direction
	if is_right:
		direction = Input.get_axis("ui_left", "ui_right")
	else:
		direction = Input.get_axis("ui_right", "ui_left")

	# Adjust glide angle based on input direction and clamp it
	glide_angle += direction * PITCH_SPEED * delta
	glide_angle = clamp(glide_angle, -MAX_PITCH_ANGLE, MAX_PITCH_ANGLE)

	if glide_buffer_jump > 1.5:
	# Calculate the adjusted speed based on glide angle and flight speed (initial inertia)
		var angle_factor = glide_angle / MAX_PITCH_ANGLE
		var adjusted_speed = flight_speed * (1.0 + angle_factor)

		# Ensure a minimum speed threshold to maintain gliding
		if adjusted_speed < 80:
			is_gliding = false

		# Apply acceleration or deceleration depending on angle and initial inertia
		flight_speed = lerp(flight_speed, adjusted_speed, delta)  # Smoothly adjust speed based on angle
	
		# Modify velocity based on glide angle and smoothed flight speed
		if is_right:
		# Moving to the right
			velocity.x = flight_speed * cos(deg_to_rad(glide_angle))  # Horizontal movement
			velocity.y = flight_speed * sin(deg_to_rad(glide_angle)) + GLIDE_GRAVITY * delta  # Vertical movement with gravity
		else:
		# Compensate for left movement by reversing the horizontal velocity
			velocity.x = -flight_speed * cos(deg_to_rad(glide_angle))  # Horizontal movement reversed
			velocity.y = flight_speed * sin(deg_to_rad(glide_angle)) + GLIDE_GRAVITY * delta  # Vertical movement with gravity
	else:
	# Apply gravity if not in glide mode
		velocity.y += GRAVITY * delta

func flap(power):
	power=power*10
	if power<3:
		power = 3
	velocity.y = FLAP_STRENGTH*power  # Strong upwards momentum
	flap_cooldown_timer = FLAP_COOLDOWN  # Reset the flap cooldown
	animatedSprite.animation="flapping"
	flap_lock=true
func rotate_bird_based_on_velocity():
	# Rotate the bird to simulate tilting while gliding (or falling)
	var target_angle = lerp_angle(rotation, clamp(velocity.y / 100.0, -PI / 8, PI / 4), 0.1)
	rotation = target_angle


func _on_area_2d_area_entered(area: Area2D) -> void:
	blackness=10
