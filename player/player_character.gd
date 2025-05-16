class_name PlayerCharacter
extends CharacterBody3D

@onready var _camera: Camera3D = %Camera3D

@export var walk_speed: float = 5.0
@export var run_speed: float = 8.0
@export var crouch_speed: float = 2.0
@export var jump_power: float = 4.5
@export var stand_height: float = 1.75
@export var crouch_height: float = 0.9999

@export var player_strength: float = 100
@export var strength_multiplier: float = 1.4

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
		if is_on_floor() and not %CrouchCheck.is_colliding():
			global_position.y -= ((stand_height - crouch_height) / 2)
	elif Input.is_action_just_released("crouch"):
		is_crouching = false
		if is_on_floor() and not %CrouchCheck.is_colliding():
			global_position.y += ((stand_height - crouch_height) / 2)

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
	var direction := (transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()
	if direction:
		velocity.z = direction.z * _current_speed
		velocity.x = direction.x * _current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, _current_speed)
		velocity.z = move_toward(velocity.z, 0, _current_speed)

	move_and_slide()
	
	# !BUG: When jumping while colliding, sometimes rigidbody goes FLYING.
	push_rigid_body()

##########################################################################################################
### Taken from LesusX(https://github.com/LesusX/YouTube/tree/main), thanks for the awesome snippet!

# Function to handle pushing a RigidBody3D
func push_rigid_body() -> void:
	# Get the last collision data
	var col := get_last_slide_collision()
	if col:
		# Retrieve the collider and collision position
		var col_collider := col.get_collider()
		var col_position := col.get_position()

		# Check if the collider is a RigidBody3D
		if col_collider is RigidBody3D:
			var body_mass = col_collider.mass
			# Retrieve all connected bodies to the collider
			var all_connected_bodies = get_all_connected_bodies(col_collider)
			# Calculate friction for the connected bodies
			var friction = calculate_friction(all_connected_bodies)
			
			var total_mass = 0.0
			# Calculate the total mass of all connected bodies
			for body in all_connected_bodies:
				total_mass += body.mass
			
			# Define which sides of the pushed body are free or blocked
			var free_sides = {
				"LEFT": true,
				"RIGHT": true,
				"FRONT": true,
				"BACK": true,
				"TOP": true,
				"BOTTOM": false # Bottom is always blocked since it's being pushed
			}

			# Check each side for connected bodies
			for connected_body in all_connected_bodies:
				if connected_body == col_collider:
					continue
				
				# Get the position of the connected body relative to the pushed body
				var connected_local_pos = col_collider.to_local(connected_body.global_position)
				
				# Determine if the connected body blocks any axis (x, z, y)
				if abs(connected_local_pos.x) > abs(connected_local_pos.z):
					if connected_local_pos.x < 0:
						free_sides["LEFT"] = false
					else:
						free_sides["RIGHT"] = false
				elif abs(connected_local_pos.z) > abs(connected_local_pos.x):
					if connected_local_pos.z < 0:
						free_sides["FRONT"] = false
					else:
						free_sides["BACK"] = false
				if abs(connected_local_pos.y) > max(abs(connected_local_pos.x), abs(connected_local_pos.z)):
					if connected_local_pos.y > 0:
						free_sides["TOP"] = false
					else:
						free_sides["BOTTOM"] = false

			# If all sides except bottom are free, only consider the pushed body's mass
			if free_sides["LEFT"] and free_sides["RIGHT"] and free_sides["FRONT"] and free_sides["BACK"] and free_sides["TOP"]:
				total_mass = body_mass
				friction = 0.0
			else:
				# Include connected bodies' mass if sides are blocked
				total_mass = body_mass
				for connected_body in all_connected_bodies:
					total_mass += connected_body.mass if connected_body != col_collider else 0

			# Calculate the weight of stacked bodies above the pushed body
			var stacked_weight = 0.0
			for connected_body in all_connected_bodies:
				if connected_body.global_position.y > col_collider.global_position.y:
					stacked_weight += connected_body.mass
			
			# Determine the effective mass (total mass + stacked weight)
			var effective_mass = total_mass + stacked_weight
			
			# Adjust the strength multiplier based on total mass
			if total_mass < 25:
				strength_multiplier = lerp(1.5, 1.8, (25 - total_mass) / 25.0)
			elif total_mass >= 25 and total_mass < 50:
				strength_multiplier = lerp(1.8, 1.5, (total_mass - 25) / 25.0)
			else:
				strength_multiplier = 1.4
	
			# Calculate the maximum speed and force to apply
			var max_speed = (player_strength * strength_multiplier) / effective_mass
			var applied_force = player_strength * strength_multiplier if effective_mass >= player_strength * strength_multiplier else effective_mass
			applied_force *= (1.0 - friction) # Adjust for friction

			# Restrict pushing if total mass exceeds player strength
			if total_mass > player_strength:
				var restricted_sides = []
				var opposite_sides = {
					"LEFT": "RIGHT",
					"RIGHT": "LEFT",
					"FRONT": "BACK",
					"BACK": "FRONT",
					"TOP": "BOTTOM",
					"BOTTOM": "TOP"
				}
				
				# Check which sides are blocked by connected bodies
				for connected_body in all_connected_bodies:
					if connected_body == col_collider:
						continue
					var connected_local_pos = col_collider.to_local(connected_body.global_position)
					var connected_side = ""
					if abs(connected_local_pos.x) > abs(connected_local_pos.z):
						connected_side = "LEFT" if connected_local_pos.x < 0 else "RIGHT"
					else:
						connected_side = "FRONT" if connected_local_pos.z < 0 else "BACK"
					if abs(connected_local_pos.y) > max(abs(connected_local_pos.x), abs(connected_local_pos.z)):
						connected_side = "TOP" if connected_local_pos.y > 0 else "BOTTOM"
					restricted_sides.append(opposite_sides[connected_side])
				
				# Determine which side the player is pushing
				var local_position = col_collider.to_local(global_position)
				var push_side = ""
				if abs(local_position.x) > abs(local_position.z):
					push_side = "LEFT" if local_position.x < 0 else "RIGHT"
				else:
					push_side = "FRONT" if local_position.z < 0 else "BACK"
				if abs(local_position.y) > max(abs(local_position.x), abs(local_position.z)):
					push_side = "TOP" if local_position.y > 0 else "BOTTOM"
				
				# Block pushing if the side is restricted
				if push_side in restricted_sides:
					var applied_force_og = player_strength * strength_multiplier if body_mass >= player_strength * strength_multiplier else body_mass
					var distance_restricted = (col_position - global_position).length()
					var distance_factor_restricted = clamp(distance_restricted / 2.0, 0.4, 1.0)
					# If the side we push against is blocked allow a small force to be applied so that the pushed body can be moved arround a bit. 
					# For example if you want to allign the pushed body flat against the conected one.
					col_collider.apply_impulse(-col.get_normal().normalized() * applied_force_og * 0.50 * distance_factor_restricted, col_position - col_collider.global_position)
					return
					
			# Apply the impulse to the collider if it's below the max speed
			if col_collider.linear_velocity.length() < max_speed:
				var push_direction = - col.get_normal().normalized()
				var distance = (col_position - global_position).length()
				
				# Adjust force based on distance for smoother interaction
				var distance_factor = clamp(distance / 2.0, 0.5, 1.0)
				col_collider.apply_impulse(push_direction * applied_force * distance_factor, col_position - col_collider.global_position)


# Function to calculate friction based on connected bodies and their masses
func calculate_friction(connected_bodies: Array) -> float:
	var total_mass = 0.0
	for body in connected_bodies:
		total_mass += body.mass
	
	# Base friction with adjustments for body count and mass
	var base_friction = 0.1
	var friction_per_body = 0.05
	var mass_friction_factor = 0.001 # Small adjustment based on mass

	# Calculate friction and clamp it within a valid range
	var friction = base_friction + (connected_bodies.size() * friction_per_body) + (total_mass * mass_friction_factor)
	return clamp(friction, 0.0, 1.0)


# Function to get all connected RigidBody3D objects
func get_all_connected_bodies(start_body: RigidBody3D, max_bodies: int = 6) -> Array:
	var connected_bodies = []
	var visited_bodies = {}
	var stack = [start_body]

	while stack and connected_bodies.size() < max_bodies:
		var current_body = stack.pop_front()

		if current_body in visited_bodies:
			continue
		visited_bodies[current_body] = true
		connected_bodies.append(current_body)

		# Stop if the max number of bodies is reached
		if connected_bodies.size() >= max_bodies:
			break

		# Check for child collision shapes
		var collision_shape = current_body.get_child(0) if current_body.get_child_count() > 0 else null
		if collision_shape is CollisionShape3D:
			var shape = collision_shape.shape
			var query = PhysicsShapeQueryParameters3D.new()
			query.shape = shape
			query.transform = current_body.global_transform
			query.set_margin(0.01)

			# Find intersecting bodies
			var space_state = get_world_3d().direct_space_state
			var result = space_state.intersect_shape(query)

			for item in result:
				var collider = item.collider
				if collider is RigidBody3D and collider != current_body and collider not in visited_bodies:
					stack.append(collider)

	return connected_bodies