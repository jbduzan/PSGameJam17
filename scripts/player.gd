extends CharacterBody2D

const SPEED = 350.0 # Base horizontal movement speed
const GRAVITY = 2000.0 # Gravity when moving upwards
const JUMP_VELOCITY = -1250.0 # Maximum jump strength
const INPUT_BUFFER_PATIENCE = 0.1 # Input queue patience time
const COYOTE_TIME = 0.08 # Coyote patience time
#const ACCELERATION = 1200.0 # Base acceleration
#const FRICTION = 1400.0 # Base friction
#const FALL_GRAVITY = 3000.0 # Gravity when falling downwards
#const FAST_FALL_GRAVITY = 5000.0 # Gravity while holding "fast_fall"
#const WALL_GRAVITY = 25.0 # Gravity while sliding on a wall
#const WALL_JUMP_VELOCITY = -700.0 # Maximum wall jump strength
#const WALL_JUMP_PUSHBACK = 300.0 # Horizontal push strength off walls
#
#
#func _physics_process(delta) -> void:
	#if !canControl: return
	#
	## Get inputs
	#var horizontal_input := Input.get_axis("ui_left", "ui_right")
	#var jump_attempted := Input.is_action_just_pressed("ui_jump")
#
	## Add the gravity and handle jumping
	#if jump_attempted or input_buffer.time_left > 0:
		#if coyote_jump_available: # If jumping on the ground
			#velocity.y = JUMP_VELOCITY
			#coyote_jump_available = false
		#elif is_on_wall() and horizontal_input != 0: # If jumping off a wall
			#velocity.y = WALL_JUMP_VELOCITY
			#velocity.x = WALL_JUMP_PUSHBACK * -sign(horizontal_input)
		#elif jump_attempted: # Queue input buffer if jump was attempted
			#input_buffer.start()
#
	## Shorten jump if jump key is released
	#if Input.is_action_just_released("ui_jump") and velocity.y < 0:
		#velocity.y = JUMP_VELOCITY / 4
#
	## Apply gravity and reset coyote jump
	#if is_on_floor():
		#coyote_jump_available = true
		#coyote_timer.stop()
	#else:
		#if coyote_jump_available:
			#if coyote_timer.is_stopped():
				#coyote_timer.start()
		#velocity.y += get_gravity(horizontal_input) * delta
#
	## HYandle horizontal motion and friction
	#var floor_damping := 1.0 if is_on_floor() else 0.2 # Set floor damping, friction is less when in air
	#var dash_multiplier := 2 if Input.is_action_pressed("dash") else 1
	#if horizontal_input:
		#velocity.x = move_toward(velocity.x, horizontal_input * SPEED * dash_multiplier, ACCELERATION * delta)
	#else:
		#velocity.x = move_toward(velocity.x, 0, (FRICTION * delta) * floor_damping)
#
	## Apply velocity
	#move_and_slide()
#
### Returns the gravity based on the state of the player
#func get_gravity(input_dir : float = 0) -> float:
	#if Input.is_action_pressed("fast_fall"):
		#return FAST_FALL_GRAVITY
	#if is_on_wall_only() and velocity.y > 0 and input_dir != 0:
		#return WALL_GRAVITY
	#return GRAVITY if velocity.y < 0 else FALL_GRAVITY
#
enum States {IDLE, RUNNING, JUMPING, FALLING}

var state: States = States.IDLE: set = set_state
var previousState: States = States.IDLE

var input_buffer : Timer # Reference to the input queue timer
var coyote_timer : Timer # Reference to the coyote timer
var coyote_jump_available := true
#var canControl = true
#
func _ready() -> void:
	# Set up input buffer timer
	input_buffer = Timer.new()
	input_buffer.wait_time = INPUT_BUFFER_PATIENCE
	input_buffer.one_shot = true
	add_child(input_buffer)

	# Set up coyote timer
	coyote_timer = Timer.new()
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.one_shot = true
	add_child(coyote_timer)
	coyote_timer.timeout.connect(coyote_timeout)
	
func coyote_timeout() -> void:
	coyote_jump_available = false

func _physics_process(delta):
	const GROUND_STATES := [States.IDLE, States.RUNNING]
	
	var horizontal_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if state in [States.IDLE] and horizontal_input != 0:
		state = States.RUNNING
	
	if state in [States.RUNNING] and horizontal_input == 0:
		state = States.IDLE
	
	if Input.is_action_just_pressed("ui_jump"):
		if state in GROUND_STATES:
			state = States.JUMPING
		else:
			input_buffer.start()
	
	velocity.x = horizontal_input * SPEED
	velocity.y += GRAVITY * delta

	match state:
		States.RUNNING, States.IDLE:
			coyote_jump_available = true
			coyote_timer.stop()		
			
			if input_buffer.time_left > 0:
				state = States.JUMPING
		States.JUMPING:
			if coyote_jump_available:
				velocity.y = JUMP_VELOCITY
				coyote_jump_available = false
				
			state = States.FALLING
		States.FALLING:
			if is_on_floor():
				state = States.IDLE
			
			if Input.is_action_just_released("ui_jump") and velocity.y < 0:
				velocity.y *= 0.3
		States.IDLE:
			velocity = Vector2.ZERO
			
	move_and_slide()

func set_state(newState: int) -> void:
	previousState = state
	state = newState
	
	match state:
		States.IDLE:
			$AnimatedSprite2D.stop()
			print("IDLE")
		States.RUNNING:
			if Input.is_action_pressed("ui_left") || Input.is_action_just_released("ui_jump"):
				$AnimatedSprite2D.flip_h = true
			
			if Input.is_action_pressed("ui_right") || Input.is_action_just_released("ui_jump"):
				$AnimatedSprite2D.flip_h = false
			
			$AnimatedSprite2D.play("run")
			print("RUNNING")
		States.JUMPING:
			$AnimatedSprite2D.play("jump")
			print("JUMPING")
		States.FALLING:
			print("FALLING")

func death():
	#canControl = false
	visible = false
	await get_tree().create_timer(1).timeout
	reset()

func win():
	#canControl = false
	visible = false

func reset():
	await get_tree().reload_current_scene()
	visible = true
	#canControl = true
