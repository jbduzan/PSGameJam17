extends CharacterBody2D

@export var abilities: HBoxContainer
@export var abilitySlots = 0

const SPEED = 350.0 # Base horizontal movement speed
const GRAVITY = 2000.0 # Gravity when moving upwards
const JUMP_VELOCITY = -900.0 # Maximum jump strength
const INPUT_BUFFER_PATIENCE = 0.1 # Input queue patience time
const COYOTE_TIME = 0.08 # Coyote patience time
const DASH_SPEED_X = 900
const DASH_SPEED_Y = 350

enum States {IDLE, RUNNING, JUMPING, FALLING, DASHING}

var state: States = States.IDLE: set = set_state
var previousState: States = States.IDLE
var previousVelocity: Vector2
var currentGravity = GRAVITY

var input_buffer: Timer
var coyote_timer: Timer
var dashTimer: Timer
var coyote_jump_available := true
var canControl = true

func _ready() -> void:
	input_buffer = Timer.new()
	input_buffer.wait_time = INPUT_BUFFER_PATIENCE
	input_buffer.one_shot = true
	add_child(input_buffer)
	
	dashTimer = Timer.new()
	dashTimer.wait_time = .1
	dashTimer.one_shot = true
	add_child(dashTimer)
	dashTimer.timeout.connect(dash_timeout)

	coyote_timer = Timer.new()
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.one_shot = true
	add_child(coyote_timer)
	coyote_timer.timeout.connect(coyote_timeout)
		
func coyote_timeout() -> void:
	coyote_jump_available = false
	
func dash_timeout() -> void:
	var horizontal_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if not is_on_floor():
		state = States.FALLING
	elif horizontal_input != 0:
		state = States.RUNNING
	else:
		state = States.IDLE
	

func _physics_process(delta):
	if !canControl: return

	const GROUND_STATES := [States.IDLE, States.RUNNING]
	
	var horizontal_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var vertical_input = Input.get_action_strength("ui_up")
	
	if Input.is_action_just_pressed("ui_jump"):
		if state in GROUND_STATES:
			state = States.JUMPING
		else:
			input_buffer.start()
	
	if Input.is_action_just_pressed("ui_dash") and horizontal_input != 0:
		state = States.DASHING
	
	match state:
		States.RUNNING:
			if horizontal_input == 0:
				state = States.IDLE
			else:
				velocity.x = horizontal_input * SPEED
				coyote_jump_available = true
				coyote_timer.stop()
				
				if input_buffer.time_left > 0:
					state = States.JUMPING
		States.JUMPING:
			if coyote_jump_available:
				abilities.use("jump")
				velocity.y = JUMP_VELOCITY
				coyote_jump_available = false
				
			state = States.FALLING
		States.FALLING:
			if is_on_floor():
				state = States.IDLE

			if Input.is_action_just_released("ui_jump") and velocity.y < 0:
				velocity.y *= 0.3				
			
			velocity.x = horizontal_input * SPEED
			velocity.x = lerp(previousVelocity.x, velocity.x, .1)
		States.DASHING:
			abilities.use("dash")
			velocity.y = vertical_input * DASH_SPEED_Y * -1
			velocity.x = -1 * DASH_SPEED_X if horizontal_input < 0 else DASH_SPEED_X
		States.IDLE:
			if horizontal_input != 0:
				state = States.RUNNING
			else:
				velocity.x = 0
				coyote_jump_available = true
				coyote_timer.stop()		
				
				if input_buffer.time_left > 0:
					state = States.JUMPING
	
	velocity.y += currentGravity * delta
	velocity.y = lerp(previousVelocity.y, velocity.y, .8)
	
	previousVelocity = velocity			

	move_and_slide()

func set_state(newState: int) -> void:
	previousState = state
	state = newState
	var canUse = true
	
	if previousState == States.DASHING:
		currentGravity = GRAVITY
	
	match state:
		States.IDLE:
			$AnimatedSprite2D.play("idle")
			print("IDLE")
		States.RUNNING:
			if Input.is_action_pressed("ui_left") || Input.is_action_just_released("ui_jump"):
				$AnimatedSprite2D.flip_h = true
			
			if Input.is_action_pressed("ui_right") || Input.is_action_just_released("ui_jump"):
				$AnimatedSprite2D.flip_h = false
			
			$AnimatedSprite2D.play("run")
			print("RUNNING")
		States.JUMPING:
			canUse = abilities.can("jump")
			
			if canUse:
				$AnimatedSprite2D.play("jump")
				print("JUMPING")
		States.FALLING:
			print("FALLING")
		States.DASHING:
			canUse = abilities.can("dash")
			
			if canUse:
				currentGravity = 0
				dashTimer.start()
				print("DASHING")
			
	if not canUse:
		state = previousState

func death():
	canControl = false
	visible = false
	await get_tree().create_timer(1).timeout
	reset()

func win():
	canControl = false
	visible = false
	await get_tree().create_timer(1).timeout
	reset()

func reset():
	await get_tree().reload_current_scene()
	visible = true
	canControl = true
