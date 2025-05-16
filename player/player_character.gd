class_name PlayerCharacter
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var _camera: Camera3D = $Camera3D


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


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
