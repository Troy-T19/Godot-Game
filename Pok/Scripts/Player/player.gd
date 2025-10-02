extends CharacterBody2D

@export var walkspeed: int = 5

const TILE_SIZE = 64

@onready var ray = $RayCast2D

var initial_position = Vector2(0,0)
var current_direction = Vector2(0,0)
var is_moving = false
var percent_moved_to_next_tile = 0.0
var move



func _ready():
	initial_position = position
	

#process function contstantly runs when delta is put in as the varible
#checks if player is moving
#if not moving takes in player input, set the player is movng after _player_input() is ran
#if player is moving, run _move() and moves player
#else set that the payer is not moving
## This to constantly check the moving state of the player and to allow inputs depending on its state
func _process(delta):
	if is_moving == false:
		_player_input()
	elif is_moving == true:
		_move(delta)
	else:
		is_moving = false
		

#function plays when player is not moving
##This function is used to take player inputs to update the current position of the 
##player and to limit inputs on more than 1 axis
func _player_input():
	
	#checks if the player is not moving on the y axis, takes inputs from x axis, updates current on x axis
	#await allows for more delayed stepping, more 2D feeling
	if(current_direction.y==0):
		current_direction.x = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
		await get_tree().create_timer(0.0001).timeout
	
	#checks if the player is not moving on the x axis, takes inputs from y axis, updates current on y axis
	#await allows for more delayed stepping, more 2D feeling
	if(current_direction.x==0): 
		current_direction.y = int(Input.is_action_pressed("Down")) - int(Input.is_action_pressed("Up"))
		await get_tree().create_timer(0.0001).timeout
	
	#If the position of the player is not 0,0 , set the moving status to true to is can be process by the _move func
	if(current_direction != Vector2(0,0)):
		initial_position = position
		is_moving = true
	
func _move(delta):
	
	var desired_step = (current_direction * TILE_SIZE) / 2
	print(desired_step)
	ray.target_position = desired_step
	ray.force_raycast_update()
	
	if(not ray.is_colliding()):
		percent_moved_to_next_tile += delta * walkspeed
		
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (TILE_SIZE * current_direction)
			percent_moved_to_next_tile = 0.0
			is_moving = false
		else:
			position = initial_position + (TILE_SIZE * current_direction * percent_moved_to_next_tile)
	else :
		is_moving = false
