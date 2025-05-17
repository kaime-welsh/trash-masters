class_name FPSCharacter
extends CharacterBody3D

@onready var _camera: Camera3D = %Camera3D

@export_category("Input Settings")
@export var mouse_sensitivity: float = 0.006
@export var auto_bhop: bool = true

@export_category("Ground Movement")
@export var walk_speed: float = 7.0
@export var sprint_speed: float = 8.5
@export var ground_accel: float = 14.0
@export var ground_decel: float = 10.0
@export var ground_friction: float = 6.0

@export_category("Air Movement")
@export var jump_velocity: float = 6.0
@export var air_cap: float = 0.85
@export var air_accel: float = 800.0
@export var air_move_speed: float = 500.0

@export_category("Physics Interactions")
@export var push_strength: float = 5
@export var mass: float = 80

const HEADBOB_MOVE_AMOUNT = 0.06
const HEADBOB_FREQUENCY = 2.4

var input_dir: Vector2
var wish_dir: Vector3
var headbob_time: float = 0.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func get_move_speed() -> float:
	return sprint_speed if Input.is_action_pressed("sprint") else walk_speed


func is_surface_too_steep(normal: Vector3) -> bool:
	var max_slope_angle_dot = Vector3(0, 1, 0).rotated(Vector3(1.0, 0, 0), self.floor_max_angle).dot(Vector3(0, 1, 0))
	if normal.dot(Vector3(0, 1, 0)) < max_slope_angle_dot:
		return true
	return false


func clip_velocity(normal: Vector3, overbounce: float, delta: float) -> void:
	var backoff := self.velocity.dot(normal) * overbounce
	if backoff >= 0: return
	
	var change := normal * backoff
	self.velocity -= change * delta

	var adjust := self.velocity.dot(normal)
	if adjust < 0.0:
		self.velocity -= normal * adjust


func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotate camera based on mouse movement
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * mouse_sensitivity)
			_camera.rotate_x(-event.relative.y * mouse_sensitivity)
			# Clamp rotation to avoid flipping
			_camera.rotation.x = clamp(_camera.rotation.x, -PI / 2, PI / 2)

		# Release mouse on escape
		if Input.is_action_just_pressed("quit"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Capture mouse on click
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Get movement direction
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward").normalized()


func _handle_air_physics(delta) -> void:
	# Acceleration and physics in air
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	var cur_speed_in_wish_dir := self.velocity.dot(wish_dir)
	var capped_speed = min((air_move_speed * wish_dir).length(), air_cap)
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = air_accel * air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir
		
	if is_on_wall():
		if is_surface_too_steep(get_wall_normal()):
			self.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		else:
			self.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		clip_velocity(get_wall_normal(), 1, delta)


func _handle_ground_physics(delta) -> void:
	# Acceleration and friction on ground
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	var add_speed_till_cap = get_move_speed() - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = ground_accel * delta * get_move_speed()
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir
	
	# Apply friction
	var control = max(self.velocity.length(), ground_decel)
	var drop = control * ground_friction * delta
	var new_speed = max(self.velocity.length() - drop, 0.0)
	if self.velocity.length() > 0:
		new_speed /= self.velocity.length()
	self.velocity *= new_speed

	_headbob_effect(delta)


func _physics_process(delta: float) -> void:
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)

	if is_on_floor():
		if Input.is_action_just_pressed("jump") or (auto_bhop and Input.is_action_pressed("jump")):
			self.velocity.y = jump_velocity
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)

	_push_away_rigid_bodies()
	move_and_slide()


func _headbob_effect(delta: float) -> void:
	headbob_time += delta * self.velocity.length()
	_camera.transform.origin = Vector3(
		cos(headbob_time * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUNT,
		sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUNT,
		0,
	)


func _push_away_rigid_bodies():
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal()
			# How much velocity the object needs to increase to match player velocity in the push direction
			var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			# Only count velocity towards push dir, away from character
			velocity_diff_in_push_dir = max(0., velocity_diff_in_push_dir)
			# Objects with more mass than us should be harder to push. But doesn't really make sense to push faster than we are going
			var mass_ratio = min(1., mass / c.get_collider().mass)
			# Optional add: Don't push object at all if it's 4x heavier or more
			if mass_ratio < 0.25:
				continue
			# Don't push object from above/below
			push_dir.y = 0
			var push_force = mass_ratio * push_strength
			c.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, c.get_position() - c.get_collider().global_position)