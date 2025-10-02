extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -400.0
const WALL_SLIDE_GRAVITY = 75 
const WALL_PUSHBACK = 00


var dash_speed = 300
var last_falling_height = 0
var last_wall_position : Array[float] = [1]
var wall_jump_position
var dashing = false
var can_dash = true
var can_jump = true
var is_falling = false
var is_wall_sliding = false
var falling_height
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	
	falling_height = velocity.y
	wall_jump_position = snapped(position.x,0.01)
	print(wall_jump_position)
	print(last_wall_position)
	#print(count)
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	if is_on_floor():
		can_jump = true
		last_wall_position[0] = 1
	
	Falling(falling_height)
	Jump()
	Dash()
	Walk_Dash()
	move_and_slide()
	Wall_Slide(delta)
	

func Jump():
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and can_jump:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		if is_on_wall() and Input.is_action_pressed("ui_right") and is_wall_sliding and not is_on_floor() and not (last_wall_position[0] == wall_jump_position):
			velocity.x = -WALL_PUSHBACK
			velocity.y = JUMP_VELOCITY
			last_wall_position[0] = snapped(position.x,0.01) #Snapped function prevents extra wall jumps from the same wall due to small decimal differences by rounding up floats
			move_and_slide()
			print("pushback")
			
		if is_on_wall() and Input.is_action_pressed("ui_left") and is_wall_sliding and not is_on_floor() and not (last_wall_position[0] == wall_jump_position):
			velocity.x = WALL_PUSHBACK
			velocity.y = JUMP_VELOCITY
			last_wall_position[0] = snapped(position.x,0.01) #Snapped function prevents extra wall jumps from the same wall due to small decimal differences by rounding up floats
			move_and_slide()
			print("pushback")
			


func Dash():
	if Input.is_action_pressed("ui_down") and can_dash:
		dashing = true
		can_dash = false
		$Dashing_timer.start()
		$Dash_again_timer.start()


func Walk_Dash():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		if dashing:
			velocity.x = direction * dash_speed
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


func Wall_Slide(delta):
	if is_on_wall() and not is_on_floor() and is_falling and velocity.y > 0:
			is_wall_sliding = true
			velocity.y = WALL_SLIDE_GRAVITY
			#print("True")
	elif is_on_floor() and not is_on_wall():
			velocity.y += gravity * delta
			is_wall_sliding = false


func Falling(falling_height):
	if (falling_height > last_falling_height):
		is_falling = true
	
	last_falling_height = falling_height


func _on_timer_timeout():
	dashing = false


func _on_dash_again_timer_timeout():
	can_dash = true



#fix x position diuble jump on same wall
