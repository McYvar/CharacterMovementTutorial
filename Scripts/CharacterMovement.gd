extends CharacterBody2D

# Variables
@export var walk_speed = 300
@export var run_speed = 600

@export var reset_velocity_on_jump = true
@export var jump_force = -500

@export var walljump_amount = 3

@export var dash_length = 100
@export var dash_speed = 700

var direction = 0

var performed_walljumps = 0

var is_dashing = false
var dash_starting_position = 0
var dash_current = 0
var dash_direction = 0

var dash_cooldown = 3.0 # Requires .0 to be a fracture
var dash_cooldown_timer = 0.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Explain ready? Max fps set to explain delta
func _ready():
	Engine.max_fps = 1000

func _physics_process(delta):
	process_gravity(delta)
	
	move() # Explain that the code starts running on the line with func move(delta)
	jump()
	dash(delta)
	
	move_and_slide()

func process_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func move():
	# Basic functionality to move the character using the A and D keys <-- Comment, not needed in the actual code
	direction = Input.get_axis("walk_left", "walk_right")
	
	var speed
	
	if (Input.is_action_pressed("sprint")):
		speed = run_speed
	else:
		speed = walk_speed
	
	velocity.x = direction * speed

func jump(): # Do casual floor jump first
	if (is_on_floor()):
		floor_jump()
		performed_walljumps = walljump_amount
	elif (is_on_wall()):
		wall_jump()

func floor_jump():
	if (Input.is_action_just_pressed("jump")):
		if (reset_velocity_on_jump):
			velocity.y = 0
			
		velocity.y += jump_force

func wall_jump():
	if (Input.is_action_just_pressed("jump")):
		if (performed_walljumps > 0):
			if (reset_velocity_on_jump):
				velocity.y = 0
				
			velocity.y += jump_force
			
			performed_walljumps -= 1
		print("use walljump, remaining walljumps: %s" % performed_walljumps)

func dash(delta):
	if (Input.is_action_just_pressed("dash") and direction != 0 and not is_dashing and dash_cooldown_timer < 0):
		dash_direction = direction
		is_dashing = true
		dash_starting_position = position.x
		dash_current = 0
		dash_cooldown_timer = dash_cooldown
	
	if (is_dashing):
		if (abs(dash_current) > dash_length or is_on_wall()):
			is_dashing = false
			return # Explain we turn away from the function earlier
			
		velocity.x = dash_direction * dash_speed
		dash_current += position.x - dash_starting_position
	elif (dash_cooldown_timer >= 0):
		dash_cooldown_timer -= delta


# comment and uncomment using ctrl+/
