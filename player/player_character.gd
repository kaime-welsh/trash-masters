class_name PlayerCharacter
extends CharacterBody3D

@onready var _camera: Camera3D = %Camera3D

@export var walk_speed: float = 5.0
@export var run_speed: float = 10.0
@export var crouch_speed: float = 2.0
@export var jump_power: float = 4.0
@export var stand_height: float = 1.7
@export var crouch_height: float = 0.8

var is_crouching: bool = false
var is_sprinting: bool = false

var _current_speed: float = walk_speed
var _input_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotate camera based on mouse movement
		# TODO: Make sensitivity an export variable
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * 0.005)
			_camera.rotate_x(-event.relative.y * 0.005)

			# Clamp rotation to avoid flipping
			_camera.rotation.x = clamp(_camera.rotation.x, -PI / 2, PI / 2)

		# Release mouse on escape
		if Input.is_action_just_pressed("quit"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Capture mouse on click
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_power

	# Handle crouch
	if Input.is_action_just_pressed("crouch"):
		is_crouching = true
	elif Input.is_action_just_released("crouch"):
		is_crouching = false

	# Handle sprint.
	if Input.is_action_pressed("sprint"):
		is_sprinting = true
	elif Input.is_action_just_released("sprint"):
		is_sprinting = false

	# Get movement direction
	_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_crouching:
		$CollisionShape3D.shape.height = crouch_height
		$Mesh.mesh.height = crouch_height
		_camera.position.y = (crouch_height / 2) - 0.2
	elif not %CrouchCheck.is_colliding():
		$CollisionShape3D.shape.height = stand_height
		$Mesh.mesh.height = stand_height
		_camera.position.y = (stand_height / 2) - 0.2

	# Manage speed based on state
	if is_on_floor():
		_current_speed = walk_speed
		
		if is_crouching:
			_current_speed = crouch_speed
		elif not is_crouching:
			_current_speed = walk_speed

			if is_sprinting:
				_current_speed = run_speed

		if %CrouchCheck.is_colliding():
			_current_speed = crouch_speed


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := (transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()
	if direction:
		velocity.z = direction.z * _current_speed
		velocity.x = direction.x * _current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, _current_speed)
		velocity.z = move_toward(velocity.z, 0, _current_speed)

	move_and_slide()
