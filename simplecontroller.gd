extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Speed variable to control movement speed
@export var speed: float = 200.0

func _process(delta: float) -> void:
	var movement = Vector2.ZERO

	# Horizontal movement
	if Input.is_action_pressed("right"):
		movement.x += 1
	if Input.is_action_pressed("left"):
		movement.x -= 1

	# Vertical movement
	if Input.is_action_pressed("down"):
		movement.y += 1
	if Input.is_action_pressed("up"):
		movement.y -= 1

	# Normalize the vector to avoid faster diagonal movement
	if movement != Vector2.ZERO:
		movement = movement.normalized()

	# Apply movement
	position += movement * speed * delta
