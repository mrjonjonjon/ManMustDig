extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.

# Speed variables for control
@export var max_speed: float = 200.0  # Maximum speed the object can reach
@export var acceleration: float = 400.0  # How fast it accelerates
@export var deceleration: float = 400.0  # How fast it decelerates (friction)
@export var rotation_speed: float = 10.0  # How fast the object rotates (if needed)

var process_list=[]
# Current velocity of the RigidBody2D
var velocity: Vector2 = Vector2.ZERO
# Called every frame. 'delta' is the elapsed time since the previous frame.
func process_collision(body) -> void:
	# Check if the collided area is part of the "ground" group
	if not body.is_in_group("ground"):
		return
	
	# Get the main polygon points for the current node (the "drill" polygon)
	var polygon_points_a = $Polygon.get_polygon()
	var polygons_a: Array = $Polygon.get_polygons()
	var global_polygon_points_a = Array(polygon_points_a).map(func(p): return $Polygon.to_global(p))
	
	# Get the polygon data for the overlapping area (the ground)
	var polygon_points_b = body.get_node("Polygon").get_polygon()
	var polygons_b: Array = body.get_node("Polygon").get_polygons()
	var global_polygon_points_b = Array(polygon_points_b).map(func(p): return body.to_global(p))

	# Prepare lists for all clipped polygons
	var all_clipped_polygons = []
	var final_a = []
	var final_b = []
	
	# Prepare polygon point lists based on available data
	if polygons_a.size() > 0:
		for indices_a in polygons_a:
			final_a.append(Array(indices_a).map(func(i): return $Polygon.to_global(polygon_points_a[i])))
	else:
		final_a = [global_polygon_points_a]

	if polygons_b.size() > 0:
		for indices_b in polygons_b:
			final_b.append(Array(indices_b).map(func(i): return body.to_global(polygon_points_b[i])))
	else:
		final_b = [global_polygon_points_b]

	# Perform the clipping of polygons
	for p_a in final_a:
		for p_b in final_b:
			var clipped = Geometry2D.clip_polygons(p_b, p_a)
			if clipped.size() > 0:
				all_clipped_polygons.append_array(clipped)

	# Flatten clipped polygons to set in $Polygon and prepare for collisions
	var pti = {}
	var new_polygon = []
	var newps = []
	var i = 0

	for p in all_clipped_polygons:
		var newp = []
		for po in p:
			new_polygon.append(body.get_node("Polygon").to_local(po))
			pti[po] = i
			i += 1
			newp.append(po)
		newps.append(newp)

	# Update Polygon points and create indices
	body.get_node("Polygon").set_polygon(new_polygon)
	var indices = []
	for p in newps:
		var pi = []
		for po in p:
			pi.append(pti[po])
		indices.append(pi)

	body.get_node("Polygon").set_polygons(indices)

	# Update collision shapes based on the clipped polygons
	# Remove existing collision shapes to prevent duplicates
	for child in body.get_children():
		if child is CollisionPolygon2D:
			child.queue_free()
	
	# Create new collision shapes for each clipped polygon
	for clipped_polygon in all_clipped_polygons:
		var new_collision = CollisionPolygon2D.new()
		new_collision.polygon = Array(clipped_polygon).map(func(p): return body.get_node("Polygon").to_local(p))
		body.add_child(new_collision)
		new_collision.set_owner(body)  # Set owner to allow collision shape to function in the tree
	
	return




func _process(delta: float) -> void:
	print(process_list)
	if Input.is_anything_pressed():
		set_collision_mask_value(1,0)
	else:
		set_collision_mask_value(1,1)
		
	print(get_collision_mask_value(1))
	var target_velocity = Vector2.ZERO
	
	# Horizontal movement (input handling)
	if Input.is_action_pressed("right"):
		target_velocity.x += 1
	if Input.is_action_pressed("left"):
		target_velocity.x -= 1
	
	# Vertical movement (input handling)
	if Input.is_action_pressed("down"):
		target_velocity.y += 1
	if Input.is_action_pressed("up"):
		target_velocity.y -= 1

	# Normalize the target velocity to avoid faster diagonal movement
	if target_velocity != Vector2.ZERO:
		target_velocity = target_velocity.normalized() * max_speed
	
	# Apply acceleration to reach the target velocity smoothly
	# Calculate velocity change based on input direction and acceleration/deceleration
	var velocity_change = target_velocity - velocity
	
	if velocity_change.length() > 0:
		# Accelerate toward the target velocity
		velocity += velocity_change.normalized() * acceleration * delta
		# Clamp the velocity to the maximum speed
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
	else:
		# Apply deceleration (friction) when no input is given
		if velocity.length() > 0:
			var deceleration_direction = velocity.normalized()
			velocity -= deceleration_direction * deceleration * delta
			# Stop the object if the velocity is very small
			#if velocity.length() < 10:
			#		velocity = Vector2.ZERO

	# Apply the velocity to the rigidbody's linear velocity
	linear_velocity = velocity
	#position+=velocity*0.1
	if Input.is_anything_pressed():
		for body in process_list:
			process_collision(body)
	
	# Optional: Stop the object from rotating (if not needed)
	#angular_velocity = 0


func _on_body_entered(body: Node) -> void:
	process_list.append(body)
	


func _on_body_exited(body: Node) -> void:
	process_list.erase(body)
