extends CharacterBody3D

# Constants for movement
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Mouse sensitivity
var mouse_sensitivity = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Variables for ball interaction
var ball = null
var holding_ball = false


#throwing force
const THROW_FORCE = 10

# Distance to interact with the ball
const INTERACT_DISTANCE = 2.0

# Camera reference
@onready var camera = $Camera
@onready var hand_position = $HandPosition

# Rotation variables
var rotation_x = 0.0
var rotation_y = 0.0

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	# Capture the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true

func _input(event):
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		# Update rotation based on mouse motion
		rotation_y -= event.relative.x * mouse_sensitivity
		rotation_x -= event.relative.y * mouse_sensitivity

		# Clamp vertical rotation to avoid flipping
		rotation_x = clamp(rotation_x, -90, 90)

		# Apply rotation to the player and the camera
		rotation_degrees.y = rotation_y
		camera.rotation_degrees.x = rotation_x

	if event.is_action_pressed("interact"):
		print('e')
		if holding_ball:
			drop_ball.rpc()
		else:
			try_pick_up_ball.rpc()

	if event.is_action_pressed("throw"):
		if holding_ball:
			throw_ball.rpc()

func _physics_process(delta):
	if not is_multiplayer_authority():return
	# Add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration
	# As good practice, you should replace UI actions with custom gameplay actions
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = Vector3.ZERO

	# Calculate the direction relative to the camera's orientation
	if input_dir != Vector2.ZERO:
		var forward = camera.global_transform.basis.z.normalized()
		var right = camera.global_transform.basis.x.normalized()
		direction = (forward * input_dir.y + right * input_dir.x).normalized()

	if direction != Vector3.ZERO:
		var velocity_vector = direction * SPEED
		velocity.x = velocity_vector.x
		velocity.z = velocity_vector.z
	else:
		velocity.x = 0
		velocity.z = 0
#		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
#		velocity.z = move_toward(velocity.z, 0, SPEED * delta)

	move_and_slide()

@rpc("call_local")
func try_pick_up_ball():
	# Cast a ray from the camera to detect the ball
	var params = PhysicsRayQueryParameters3D.new()
	params.from = camera.global_transform.origin
	params.to = camera.global_transform.origin - camera.global_transform.basis.z.normalized() * INTERACT_DISTANCE
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(params)


	if result.collider.is_in_group("pickupable"):
		ball = result.collider
		holding_ball = true
		ball.set_player(self)

@rpc("call_local")
func drop_ball():
	if ball:
		holding_ball = false
		ball = null

func is_holding_ball():
	return holding_ball

@rpc("call_local")
func throw_ball():
	if ball:
		var throw_direction = camera.global_transform.basis.z.normalized() * -THROW_FORCE
		ball.apply_central_impulse(throw_direction)
		drop_ball()

func get_hand_position():
	# Return the position where the ball should be when held
	return hand_position.global_transform.origin
	#camera.global_transform.origin + camera.global_transform.basis.z.normalized() * 1.5
