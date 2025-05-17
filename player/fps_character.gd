class_name FPSCharacter
extends CharacterBody3D

@export var camera: Camera3D
@export var camera_smoother: Node3D
@export var collision_shape: CollisionShape3D
@export var head: Node3D
@export var stairs_below_raycast: RayCast3D
@export var stairs_ahead_raycast: RayCast3D

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

@export_category("Crouching")
@export var crouch_speed_modifier: float = 0.8
@export var crouch_height: float = 0.7
@export var crouch_jump_modifier: float = 0.9:
	set(value):
		crouch_jump_modifier = crouch_height * value

@export_category("Stairs")
@export var max_step_height = 0.5 # Raycasts length should match this. StairsAhead one should be slightly longer.

@export_category("Physics Interactions")
@export var push_strength: float = 5
@export var mass: float = 80

const HEADBOB_MOVE_AMOUNT = 0.06
const HEADBOB_FREQUENCY = 2.4

var input_dir: Vector2
var wish_dir: Vector3
var headbob_time: float = 0.0
var is_crouched: bool = false
var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor = - INF


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func get_move_speed() -> float:
	if is_crouched:
		return walk_speed * crouch_speed_modifier
	return sprint_speed if Input.is_action_pressed("sprint") else walk_speed


func is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle


func clip_velocity(normal: Vector3, overbounce: float, delta: float) -> void:
	var backoff := self.velocity.dot(normal) * overbounce
	if backoff >= 0: return
	
	var change := normal * backoff
	self.velocity -= change * delta

	var adjust := self.velocity.dot(normal)
	if adjust < 0.0:
		self.velocity -= normal * adjust


var _saved_camera_global_pos = null
func _save_camera_pos_for_smoothing():
	if _saved_camera_global_pos == null:
		_saved_camera_global_pos = %CameraSmooth.global_position


func _snap_down_to_stairs_check() -> void:
	var did_snap := false
	stairs_below_raycast.force_raycast_update()
	var floor_below: bool = stairs_below_raycast.is_colliding() and not is_surface_too_steep(stairs_below_raycast.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() == _last_frame_was_on_floor
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = KinematicCollision3D.new()
		if self.test_move(self.global_transform, Vector3(0, -max_step_height, 0), body_test_result):
			_save_camera_pos_for_smoothing()
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func _snap_up_stairs_check(delta) -> bool:
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false
	if self.velocity.y > 0 or (self.velocity * Vector3(1, 0, 1)).length() == 0: return false
	var expected_move_motion = self.velocity * Vector3(1, 0, 1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, max_step_height * 2, 0))
	var down_check_result = KinematicCollision3D.new()
	if (self.test_move(step_pos_with_clearance, Vector3(0, -max_step_height * 2, 0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		if step_height > max_step_height or step_height <= 0.01 or (down_check_result.get_position() - self.global_position).y > max_step_height: return false
		stairs_ahead_raycast.global_position = down_check_result.get_position() + Vector3(0, max_step_height, 0) + expected_move_motion.normalized() * 0.1
		stairs_ahead_raycast.force_raycast_update()
		if stairs_ahead_raycast.is_colliding() and not is_surface_too_steep(stairs_ahead_raycast.get_collision_normal()):
			_save_camera_pos_for_smoothing()
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false


func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotate camera based on mouse movement
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			# Clamp rotation to avoid flipping
			camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2)

		# Release mouse on escape
		if Input.is_action_just_pressed("quit"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Capture mouse on click
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Get movement direction
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward").normalized()


@onready var _original_capsule_height: float = collision_shape.shape.height
func _handle_crouch(delta) -> void:
	var was_crouched_last_frame = is_crouched
	if Input.is_action_pressed("crouch"):
		is_crouched = true
	elif is_crouched and not self.test_move(self.transform, Vector3(0, crouch_height, 0)):
		is_crouched = false
	
	var translate_y_if_possible := 0.0
	if was_crouched_last_frame != is_crouched and not is_on_floor() and not _snapped_to_stairs_last_frame:
		translate_y_if_possible = crouch_jump_modifier if is_crouched else -crouch_jump_modifier
	
	if translate_y_if_possible != 0.0:
		var result = KinematicCollision3D.new()
		self.test_move(self.transform, Vector3(0, translate_y_if_possible, 0), result)
		self.position.y += result.get_travel().y
		head.position.y -= result.get_travel().y
		head.position.y = clampf(head.position.y, -crouch_height, 0.0)
	
	head.position.y = move_toward(head.position.y, -crouch_height if is_crouched else 0.0, 7.0 * delta)
	collision_shape.shape.height = _original_capsule_height - crouch_height if is_crouched else _original_capsule_height
	collision_shape.position.y = collision_shape.shape.height / 2


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

func _slide_camera_smooth_back_to_origin(delta):
	if _saved_camera_global_pos == null: return
	camera_smoother.global_position.y = _saved_camera_global_pos.y
	camera_smoother.position.y = clampf(camera_smoother.position.y, -crouch_height, crouch_height) # Clamp incase teleported
	var move_amount = max(self.velocity.length() * delta, walk_speed / 2 * delta)
	camera_smoother.position.y = move_toward(camera_smoother.position.y, 0.0, move_amount)
	_saved_camera_global_pos = camera_smoother.global_position
	if camera_smoother.position.y == 0:
		_saved_camera_global_pos = null # Stop smoothing camera


func _process(_delta: float) -> void:
	# TODO: Remove this later when I add an actual model, this is just for protyping
	$Mesh.mesh.height = collision_shape.shape.height


func _physics_process(delta: float) -> void:
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)

	_handle_crouch(delta)

	if is_on_floor():
		if Input.is_action_just_pressed("jump") or (auto_bhop and Input.is_action_pressed("jump")):
			self.velocity.y = jump_velocity
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)

	if not _snap_up_stairs_check(delta):
		_push_away_rigid_bodies() # Call before move_and_slide()
		move_and_slide()
		_snap_down_to_stairs_check()

	_slide_camera_smooth_back_to_origin(delta)

func _headbob_effect(delta: float) -> void:
	headbob_time += delta * self.velocity.length()
	camera.transform.origin = Vector3(
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