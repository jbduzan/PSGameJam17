extends CharacterBody2D

var abilities: AbilitiesBar
@export var abilitySlots = 0

@onready var label = $Label
@onready var wallCollider = $WallCollider
@onready var coyoteTimer = $CoyoteTimer

const SPEED = 20000.0 # Base horizontal movement speed
const GRAVITY = 2000.0 # Gravity when moving upwards
const JUMP_VELOCITY = -50000.0 # Maximum jump strength
const INPUT_BUFFER_PATIENCE = .1 # Input queue patience time
const COYOTE_TIME = 0.2 # Coyote patience time
const DASH_SPEED_X = 70000
const DASH_SPEED_Y = 35000
const WALLSLIDE_GRAVITY = 5000

enum States {IDLE, RUNNING, JUMPING, FALLING, DASHING, GLIDING, WALLBOUNCING, WALLSLIDING}

var state: States = States.IDLE: set = set_state
var previousState: States = States.IDLE
var previousVelocity: Vector2
var currentGravity = GRAVITY
var direction: int = 1
var wasOnFloor: bool = false

var input_buffer: Timer
var dashTimer: Timer
var canControl = true

func _ready() -> void:
	input_buffer = Timer.new()
	input_buffer.wait_time = INPUT_BUFFER_PATIENCE
	input_buffer.one_shot = true
	add_child(input_buffer)
	
	dashTimer = Timer.new()
	dashTimer.wait_time = .1
	dashTimer.one_shot = true
	dashTimer.timeout.connect(dash_timeout)
	add_child(dashTimer)
				
func dash_timeout() -> void:
	var horizontal_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if not is_on_floor():
		state = States.FALLING
	elif horizontal_input != 0:
		state = States.RUNNING
	else:
		state = States.IDLE
	

func is_near_wall():
	return wallCollider.is_colliding()

func _physics_process(delta):
	if !canControl: return

	const GROUND_STATES := [States.IDLE, States.RUNNING]
	
	var horizontal_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var vertical_input = Input.get_action_strength("ui_up")
	
	if wasOnFloor and not is_on_floor():
		state = States.FALLING
	
	if Input.is_action_just_pressed("ui_jump"):
		if state in GROUND_STATES or (state == States.FALLING and coyoteTimer.time_left > 0):
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
				if Input.is_action_pressed("ui_left"):
					$AnimatedSprite2D.flip_h = true
			
				if Input.is_action_pressed("ui_right"):
					$AnimatedSprite2D.flip_h = false
				
				velocity.x = horizontal_input * SPEED * delta
				coyoteTimer.stop()
			
			if input_buffer.time_left > 0:
				state = States.JUMPING
		States.JUMPING:
			velocity.y = JUMP_VELOCITY * delta
			state = States.FALLING
		States.FALLING:
			velocity.x = horizontal_input * SPEED * delta
			if Input.is_action_pressed("ui_left"):
				$AnimatedSprite2D.flip_h = true
		
			if Input.is_action_pressed("ui_right"):
				$AnimatedSprite2D.flip_h = false
			
			if is_on_floor():
				state = States.IDLE
			elif is_near_wall():
				state = States.WALLSLIDING
			else:
				if Input.is_action_just_released("ui_jump") and velocity.y < 0:
					velocity.y *= 0.3				
				
				if Input.is_action_pressed("ui_jump") and velocity.y >= 0:
					state = States.GLIDING
				else:
					velocity.x = lerp(previousVelocity.x, velocity.x, .1)
		States.DASHING:
			velocity.y = vertical_input * DASH_SPEED_Y * -1 * delta
			velocity.x = -1 * DASH_SPEED_X * delta if horizontal_input < 0 else DASH_SPEED_X * delta
		States.GLIDING:
			if Input.is_action_just_released("ui_jump"):
				state = States.FALLING
			else:
				currentGravity *= 0.5
				velocity.x = horizontal_input * SPEED * 0.5 * delta
		States.WALLSLIDING:
			if is_on_floor() or not is_near_wall():
				state = States.FALLING
			else:
				velocity.y = 0
				currentGravity = WALLSLIDE_GRAVITY
				
				if Input.is_action_pressed("ui_jump") and (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
					state = States.WALLBOUNCING
		States.WALLBOUNCING:
			currentGravity = GRAVITY
			
			if Input.is_action_pressed("ui_left") and direction == 1:
				velocity.x = 450 * -1 * delta
				velocity.y = JUMP_VELOCITY * .7 * delta
				abilities.use("wallBounce")
			elif Input.is_action_pressed("ui_right") and direction == -1:
				velocity.x = 450 * delta
				velocity.y = JUMP_VELOCITY * .7 * delta
				abilities.use("wallBounce")
				
			state = States.FALLING
		States.IDLE:
			if horizontal_input != 0:
				state = States.RUNNING
			else:
				velocity.x = 0
				coyoteTimer.stop()
				
			if input_buffer.time_left > 0:
					state = States.JUMPING
	
	velocity.y += currentGravity * delta
	velocity.y = lerp(previousVelocity.y, velocity.y, .8)
	# TODO MAX GRAVITY
	previousVelocity = velocity
	
	direction = 1 if not $AnimatedSprite2D.flip_h else -1
	wallCollider.rotation_degrees = 90 * -direction
	wasOnFloor = is_on_floor()

	move_and_slide()

func set_state(newState: int) -> void:
	previousState = state
	state = newState
	var canUse = true
	
	if previousState in [States.DASHING, States.GLIDING, States.WALLSLIDING]:
		currentGravity = GRAVITY
	
	match state:
		States.IDLE:
			$AnimatedSprite2D.play("idle")
			print("IDLE")
		States.RUNNING:
			$AnimatedSprite2D.play("run")
			print("RUNNING")
		States.JUMPING:
			if is_on_floor() or coyoteTimer.time_left > 0:
				canUse = abilities.can("jump")

			if canUse:
				abilities.use("jump")
				$AnimatedSprite2D.play("jump")
				print("JUMPING")
		States.FALLING:
			coyoteTimer.start(COYOTE_TIME)
			print("FALLING")
		States.DASHING:
			canUse = abilities.can("dash")
			
			if canUse:
				abilities.use("dash")
				currentGravity = 0
				dashTimer.start()
				print("DASHING")
		States.GLIDING:
			canUse = abilities.can("glide")
			
			if canUse:
				abilities.use("glide")
				print("GLIDING")
		States.WALLSLIDING:
			print("WALLSLIDING")
		States.WALLBOUNCING:
			canUse = abilities.can("wallBounce")
			
			if canUse:
				print("WALLBOUNCING")
			
	if not canUse:
		state = previousState
		
	label.text = States.keys()[state]

func death():
	canControl = false
	visible = false
	await get_tree().create_timer(1).timeout
	reset()

func win():
	canControl = false
	visible = false
	await get_tree().create_timer(.5).timeout
	
	var currentSceneFile = get_tree().current_scene.scene_file_path
	var nextLvlNumber = currentSceneFile.to_int() + 1
	var nextLvlPath = "res://scenes/levels/level_" + str(nextLvlNumber) + ".tscn"
	
	var dir = DirAccess.open("res://scenes/levels")
	if dir and dir.file_exists(nextLvlPath):
		get_tree().change_scene_to_file(nextLvlPath)
	else:
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func reset():
	await get_tree().reload_current_scene()
	visible = true
	canControl = true
