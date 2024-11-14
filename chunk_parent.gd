@tool
extends Node2D

@export var chunk_length: float = 100:
	set(value):
		queue_redraw()
		chunk_length=value  

var chunk_side_length:float =300.0
@export var num_chunks: int = 10:
	set(value):
		queue_redraw()
		num_chunks=value

@export var chunk_prefab: PackedScene              # Prefab scene for each chunk
	
# Flag to indicate whether we are in the editor (not during runtime)
var is_in_editor: bool = false

# Make the script run in the editor using the 'tool' keyword

func _ready() -> void:
	if Engine.is_editor_hint():  # Check if we are in the editor (not playing the game)
		is_in_editor = true
	else:
		# Instantiate chunks only at runtime (when the game is running)
		for x in range(num_chunks):
			for y in range(num_chunks):
				var chunk_instance = chunk_prefab.instantiate()
				chunk_instance.position = Vector2(x * chunk_length, y * chunk_length)
				add_child(chunk_instance)

	# Trigger drawing only if in the editor mode (this ensures the chunks are visualized)
	if is_in_editor:
		queue_redraw()

# Called every frame, updates the visual representation in the editor
func _draw() -> void:
	# Set the color for the chunk grid visualization
	var chunk_color = Color(0.7, 0.7, 0.7, 0.5)  # Light gray with transparency for visibility

	# Draw the grid of chunks in the editor
	for x in range(num_chunks):
		for y in range(num_chunks):
			var chunk_position = Vector2(x * chunk_length, y * chunk_length)
			draw_rect(Rect2(chunk_position, Vector2(chunk_side_length, chunk_side_length)), chunk_color)
			
			
func _set(property, value) -> bool:
	if property == "chunk_length" or property == "num_chunks":
		# Trigger the redrawing whenever these properties change
		queue_redraw() 
		return true# This calls _draw again to visualize changes in chunk length or number of chunks
	return false  # Return false to let the engine handle the rest
